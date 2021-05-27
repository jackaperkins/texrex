extends Control

var original_image = Image.new() # image data
var image = Image.new()

var result = Image.new()

onready var modifiers_container = $main_split/Panel/VBoxContainer/modifiers_container
onready var file_name_label = $"main_split/main area/Menubar/HBoxContainer/PanelContainer/Filename"
onready var drop_visualizer = $main_split/Panel/DropVisualizer
onready var renderIndicator:Panel = $"main_split/main area/Menubar/HBoxContainer/Container/RenderIndicator"

var texture = ImageTexture.new() # texture version that can be shown inside a sprite


const modifier_resolution = preload("res://modifiers/resolution/modifier_resolution.tscn")
const modifier_constrast = preload("res://modifiers/contrast/modifier_contrast.tscn")
const modifier_pallette = preload("res://modifiers/pallette/modifier_pallette.tscn")
const modifier_noise = preload("res://modifiers/noise/modifier_noise.tscn")

var modifiers = []

# pan canvas
var is_panning = false

# modifier dragging
var is_dragging = false
var dragging_node = null

var potential_index = 0

func _ready():
	#instance default modifiers
	drop_visualizer.visible = false
	for child in modifiers_container.get_children():
		child.queue_free()
	add_modifier(modifier_pallette)
	add_modifier(modifier_constrast)
	add_modifier(modifier_noise)
	add_modifier(modifier_resolution)

func modifier_order_updated():
	modifiers = []
	for child in modifiers_container.get_children():
		modifiers.append(find_modifier(child))
	process_all()

func process_all():
	modifiers[modifiers.size()-1].needs_processing = true
	_on_modifier_updated()

func add_modifier(scene):
	var mod = scene.instance()
	modifiers_container.add_child(mod)
	
	# we use find_modifier to grab the actual modifier node
	# as the child class scenes will wrap it in another node
	var modifier:Modifier = find_modifier(mod)
	modifier.connect("updated", self, "_on_modifier_updated")
	modifier.modifier_parent = self #this is bad? should we use signals? (yes)
	modifiers.append(modifier)
	
func start_drag(node):
	drop_visualizer.visible = true
	is_dragging = true
	dragging_node = node
	
func end_drag():
	if modifiers_container.get_child(potential_index) != dragging_node:
		modifiers_container.move_child(dragging_node, potential_index)
		modifier_order_updated()
	dragging_node = null
	drop_visualizer.visible = false
	is_dragging = false

func _on_modifier_updated():
	var updating = false
	if original_image.get_size().length() == 0:
		print('skipping modifiers stack, no image loaded')
		return
	# walk backwards through array, bottom to top
	result = Image.new()
	var i = modifiers.size() - 1
	while i >= 0:
		var modifier = modifiers[i]
		if updating or modifier.needs_processing: 
			updating = true  # once we hit a modifier that did update, everyone must
			print('processing modifier node: ' + modifier.name)
			
			# get the previous image data in the stack, or original if we're at end
			var image = Image.new()
			image.copy_from(original_image)
			if i < modifiers.size() - 1:
				image.copy_from(modifiers[i+1].image)
			if modifier.skip:
				modifier.image = image
			else:
				var function = modifier.process_image(image)
				# special case to wait for a  yield if our modifier is a coroutine
				if function is GDScriptFunctionState && function.is_valid():
					yield(function, "completed")
					renderIndicator.set_rotation(renderIndicator.get_rotation()+0.2)
			result.copy_from(modifier.image)
		i -= 1
		
	texture.create_from_image(result,3)
	$canvas_root/MainTexture.texture = texture

# return a modifier or childclass somewhere in the node/children
func find_modifier(node:Node):
	if node is Modifier:
		return node
	else:
		for n in node.get_children():
			if n is Modifier:
				return n

func _process(delta):
	if Input.is_action_just_pressed('middle_mouse'):
		is_panning = true
	elif Input.is_action_just_released('middle_mouse'):
		is_panning = false

func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			$canvas_root.rect_scale += Vector2(0.1, 0.1)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			$canvas_root.rect_scale-= Vector2(0.1, 0.1)
	if event is InputEventMouseMotion:
		if is_panning:
			$canvas_root.rect_position += event.relative
		if is_dragging:
			update_modifier_drag(event.position)
		
func update_modifier_drag(position):
	potential_index = 0
	var children = modifiers_container.get_children()
	var snapped_y = children[0].get_global_rect().position.y 
	
	# loop over children comparing out height to half middle of each child
	for child in children:
		if position.y < child.get_global_rect().position.y + child.rect_size.y/2:
			break
		else:
			potential_index += 1
			snapped_y = child.get_global_rect().position.y + child.rect_size.y

	drop_visualizer.rect_position = Vector2(0, snapped_y)

func preload_default():
	image.load('C:/Users/jacka/Documents/_projects/texrex/sample_textures/woman.jpg')
	original_image.load('C:/Users/jacka/Documents/_projects/texrex/sample_textures/rig.jpg')
	image.copy_from(original_image)
	process_all()
	
func _on_Load_pressed():
	print('loading file dialog')
	var last_directory = ''
	
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK: # If not, something went wrong with the file loading
		if config.has_section_key('memory', "last_directory"):
			last_directory = config.get_value('memory', 'last_directory')
			$open_file_dialog.current_dir = last_directory
	$open_file_dialog.popup_centered_clamped(Vector2(800,600))

func _on_open_image(path_to_image):
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err != OK: # If not, something went wrong with the file loading
		config = ConfigFile.new()
	var path = path_to_image.rsplit("/", true, 1)[0]
	config.set_value('memory', 'last_directory', path)
	print('setting path memory! ' + path)
	file_name_label.text = path_to_image
	config.save('user://settings.cfg')
	original_image.load(path_to_image)
	image.copy_from(original_image)
	process_all()

func _on_Save_pressed():
	print('loading save dialog')
	$save_file_dialog.popup_centered_clamped(Vector2(800,600))
	pass # Replace with function body.

func _on_save_file_dialog_file_selected(path):
	result.save_png(path)
	pass # Replace with function body.
	
