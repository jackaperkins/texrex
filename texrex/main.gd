# fuck unity
extends Control

var original_image = Image.new() # image data
var image = Image.new()

var result = Image.new()

var activity_spin_frames = 0

onready var modifier_resolution = load('res://modifiers/resolution/modifier_resolution.tscn')

onready var file_name_label = $"main_split/main area/VBoxContainer/Menubar/HBoxContainer/PanelContainer/Filename"
onready var renderIndicator:Panel = $"main_split/main area/VBoxContainer/Menubar/HBoxContainer/Container/RenderIndicator"

onready var canvas = $"main_split/main area/VBoxContainer/canvas"

onready var drop_visualizer = $main_split/Panel/DropVisualizer
onready var modifiers_container = $main_split/Panel/VBoxContainer/modifiers_container
onready var modifier_box = $main_split/Panel/VBoxContainer/AddModifiers
onready var delete_modifiers = $main_split/Panel/VBoxContainer/MarginContainer/DeleteModifiers
onready var delete_modifiers_container = $main_split/Panel/VBoxContainer/MarginContainer

var texture = ImageTexture.new() # texture version that can be shown inside a sprite


var modifiers = []

# modifier dragging
var is_dragging = false
var dragging_node:Node = null
var drag_delete_node = false # if we should trash it instead

var potential_index = 0

func _ready():
	#instance default modifiers
	drop_visualizer.visible = false
	delete_modifiers_container.visible = false
	
	for child in modifiers_container.get_children():
		child.free()
	
	prepend_modifier(modifier_resolution)
	modifier_order_updated()
	
	modifier_box.connect("add_modifier", self, "prepend_modifier")

func modifier_order_updated():
	modifiers = []
	for child in modifiers_container.get_children():
		modifiers.append(find_modifier(child))
	process_all()

func process_all():
	if modifiers.size() > 0:
		modifiers[modifiers.size()-1].needs_processing = true
	_on_modifier_updated()


func prepend_modifier(scene:PackedScene):
	var mod = scene.instance()
	modifiers_container.add_child(mod)
	modifiers_container.move_child(mod, 0)

	var modifier:Modifier = find_modifier(mod)
	modifier.connect("updated", self, "_on_modifier_updated")
	modifier.modifier_parent = self #this is bad? should we use signals? (yes)
	modifiers.push_front(modifier)
	modifier_order_updated()
	
func start_drag(node):
	potential_index = 0
	delete_modifiers_container.visible = true
	is_dragging = true
	dragging_node = node
	
func end_drag():
	delete_modifiers_container.visible = false
	if drag_delete_node:
		dragging_node.free()
		modifier_order_updated()
	elif modifiers_container.get_child(potential_index) != dragging_node:
		modifiers_container.move_child(dragging_node, max(0,potential_index-1))
		modifier_order_updated()
		
	dragging_node = null
	drop_visualizer.visible = false
	is_dragging = false

# our main processing function
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
					activity_spin_frames = max(8, activity_spin_frames)
			result.copy_from(modifier.image)
		i -= 1
	texture.create_from_image(result, 3)
	canvas.set_texture(texture)

# return a modifier or childclass somewhere in the node/children, like unity getComponentsInChildren<>() 
func find_modifier(node:Node):
	if node is Modifier:
		return node
	else:
		for n in node.get_children():
			if n is Modifier:
				return n

func _process(delta):
	if activity_spin_frames > 0: # wheeeee!!
		activity_spin_frames -= 1
		renderIndicator.rect_rotation += 3


func _input(event):
	if event is InputEventMouseMotion:
		if is_dragging:
			update_modifier_drag(event.position)
		
func update_modifier_drag(position):
	drop_visualizer.visible = true
	drag_delete_node = false
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
	
	if delete_modifiers.get_global_rect().has_point(position):
		drag_delete_node = true

	drop_visualizer.rect_position = Vector2(0, snapped_y)
	drop_visualizer.visible = !drag_delete_node

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
	if err == OK:
		if config.has_section_key('memory', "last_directory"):
			last_directory = config.get_value('memory', 'last_directory')
			$open_file_dialog.current_dir = last_directory
	$open_file_dialog.popup_centered_clamped(Vector2(800,600))

func _on_open_image(path_to_image):
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err != OK:
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

func _on_save_file_dialog_file_selected(path):
	result.save_png(path)
	pass # Replace with function body.
