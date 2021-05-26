extends Control

var original_image = Image.new() # image data
var image = Image.new()

var result = Image.new()

var texture = ImageTexture.new() # texture version that can be shown inside a sprite

const modifier_resolution = preload("res://modifiers/modifier_resolution.tscn")
const modifier_constrast = preload("res://modifiers/contrast/modifier_contrast.tscn")
const modifier_pallette = preload("res://modifiers/pallette/modifier_pallette.tscn")
const modifier_noise = preload("res://modifiers/noise/modifier_noise.tscn")

var modifiers = []

var is_dragging = false

func _ready():
	#instance default modifiers
	for child in $main_split/Panel/modifiers_container.get_children():
		child.queue_free()
	add_modifier(modifier_constrast)
	add_modifier(modifier_pallette)
	add_modifier(modifier_noise)
	add_modifier(modifier_resolution)


func process_all():
	modifiers[modifiers.size()-1].needs_processing = true
	_on_modifier_updated()

func add_modifier(scene):
	var mod = scene.instance()
	$main_split/Panel/modifiers_container.add_child(mod)
	
	# we use find_modifier to grab the actual modifier node
	# as the child class scenes will wrap it in another node
	find_modifier(mod).connect("updated", self, "_on_modifier_updated")
	modifiers.append(find_modifier(mod))

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
		is_dragging = true
	elif Input.is_action_just_released('middle_mouse'):
		is_dragging = false

func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			$canvas_root.rect_scale += Vector2(0.1, 0.1)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			$canvas_root.rect_scale-= Vector2(0.1, 0.1)
	if event is InputEventMouseMotion and is_dragging:
		$canvas_root.rect_position += event.relative

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
	
