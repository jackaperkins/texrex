extends Control

var original_image = Image.new() # image data
var image = Image.new()
var texture = ImageTexture.new() # texture version that can be shown inside a sprite

const modifier_resolution = preload("res://modifiers/modifier_resolution.tscn")
const modifier_constrast = preload("res://modifiers/modifier_contrast.tscn")

var modifiers = []

var is_dragging = false

func _ready():
	# instance default modifiers
	add_modifier(modifier_constrast)
	add_modifier(modifier_resolution)
	
	_on_Load_pressed()


func process_all():
	modifiers[modifiers.size()-1].needs_processing = true
	_on_modifier_updated()

func add_modifier(scene):
	var mod = scene.instance()
	$Panel/modifiers_container.add_child(mod)
	mod.connect("updated", self, "_on_modifier_updated")
	modifiers.append(mod)

func _on_modifier_updated():
	print('checking stack..')
	var updating = false
	
	# walk backwards through array, bottom to top
	var result = Image.new()
	var i = modifiers.size() - 1
	while i >= 0:
		var modifier = modifiers[i]
		if updating or modifier.needs_processing: 
			updating = true  # once we hit a modifier that did update, everyone must
			print('processing: ' + modifier.name)
			
			# get the previous image data in the stack, or original if we're at end
			var image = Image.new()
			image.copy_from(original_image)
			if i < modifiers.size() - 1:
				image.copy_from(modifiers[i+1].image)
				
			modifier.process_image(image)
			result.copy_from(modifier.image)
		i -= 1
		
	texture.create_from_image(result,3)
	$MainTexture.texture = texture

func _process(delta):
	if Input.is_action_just_pressed('middle_mouse'):
		is_dragging = true
	elif Input.is_action_just_released('middle_mouse'):
		is_dragging = false

func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			$MainTexture.rect_scale += Vector2(0.1, 0.1)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			$MainTexture.rect_scale-= Vector2(0.1, 0.1)
	if event is InputEventMouseMotion and is_dragging:
		$MainTexture.rect_position += event.relative

func _on_Load_pressed():
#	image.load('C:/Users/jacka/Documents/_projects/texrex/sample_textures/woman.jpg')
	original_image.load('C:/Users/jacka/Documents/_projects/texrex/sample_textures/rig.jpg')
	image.copy_from(original_image)

	texture.create_from_image(image,3)
	$MainTexture.texture = texture
	process_all()

