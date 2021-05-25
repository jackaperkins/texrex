extends Control

class_name Modifier

signal updated()
var needs_processing = false # flag value
var skip = false

var image = Image.new()
var modulate_color
var glow = 0

onready var secondary = $Main/Secondary

# UI stuff
func _process(delta):
	if glow > 0:
		glow = clamp(glow-delta, 0, 1)

func add_primary_child(node:Node):
	node.get_parent().remove_child(node)
	$Main/Primary.add_child(node)

func add_secondary_child(node:Node):
	node.get_parent().remove_child(node)
	$Main/Secondary/VBox.add_child(node)

func clear_placeholders():
	for child in $Main/Primary.get_children():
		child.queue_free()

	for child in $Main/Secondary/VBox.get_children():
		child.queue_free()		

func set_secondary_visible(value):
	$Main/Secondary.visible = value
	$Main/Title/ShowSecondary.pressed = value
	
func hide_secondary_toggle():
	$Main/Secondary.visible = false
	$Main/Title/ShowSecondary.visible = false
	
func set_label(text:String):
	$Main/Title/Label.text = text

# Called when the node enters the scene tree for the first time.
func _ready():
	modulate_color = self_modulate
	pass # Replace with function body.


func _on_show_toggled(button_pressed):
	$Main/Title/ShowSecondary
	$Main/Secondary.visible = button_pressed

func _on_skip_toggled(button_pressed):
	print('skip toggled ' + String(button_pressed))
	skip = button_pressed
	needs_processing = true
	emit_signal('updated')

## image processing, this is the core function that gets called for a modifer
func process_image(incoming:Image):
	pass

# utility for rendering a shader on an offscreen viewport and returning image
func process_shader(material:Material, canvas_size:Vector2, result_image):
	var view = Viewport.new()
	view.disable_3d = true
	view.render_target_update_mode = Viewport.UPDATE_ALWAYS
	view.size = canvas_size
	var rect = ColorRect.new()
	rect.material = material
	rect.rect_size = canvas_size #Vector2(256,256)
	view.add_child(rect)
	view.render_target_v_flip = true
	add_child(view)
	
	var texture:ViewportTexture
	var image_data:Image

	# dangerous scary loop where we spin waiting for the texture to render
	while true:
		texture = view.get_texture()
		image_data = texture.get_data()
		image_data.lock()
		# we know our texture is done because the pixel in the corner isn't 0 alpha
		if image_data.get_pixel(0,0).a != 0.0: #we know this throws an error, someones unhappy we're accessing a null pointer but we still get a safe value of 0,0,0,0 that we can sentinel off of!!!
			image_data.unlock()
			result_image.copy_from(image_data)
			break
		image_data.unlock()
		print('viewport yield.. waiting a frame')
		yield(get_tree(), "idle_frame")
	
