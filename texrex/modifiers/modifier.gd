extends Control

class_name Modifier

signal updated()
var needs_processing = false # flag value
var skip = false

var image = Image.new()

var modifier_parent = null # set from outside

onready var secondary = $Main/MarginContainer3/Secondary


func _process(delta):
	pass

func add_primary_child(node:Node):
	node.get_parent().remove_child(node)
	$Main/MarginContainer2/Primary.add_child(node)

# add node into secondary (toggleable) slot
func add_secondary_child(node:Node):
	node.get_parent().remove_child(node)
	$Main/MarginContainer3/Secondary/VBox.add_child(node)

func clear_placeholders():
	for child in $Main/MarginContainer2/Primary.get_children():
		child.queue_free()

	for child in $Main/MarginContainer3/Secondary/VBox.get_children():
		child.queue_free()

func set_secondary_visible(value):
	$Main/MarginContainer3.visible = value
	$Main/MarginContainer/Title/ShowSecondary.pressed = value

func hide_secondary_toggle():
	$Main/MarginContainer3.visible = false
	$Main/MarginContainer/Title/ShowSecondary.visible = false

func set_label(text:String):
	$Main/MarginContainer/Title/Label.text = text

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_show_toggled(button_pressed):
	$Main/MarginContainer3.visible = button_pressed

func _on_skip_toggled(button_pressed):
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
		# this sucks though because now we can't have alpha in shaders???
		if image_data.get_pixel(0,0).a != 0.0: #we know this throws an error, someones unhappy we're accessing a null pointer but we still get a safe value of 0,0,0,0 that we can sentinel off of!!!
			image_data.unlock()
			result_image.copy_from(image_data)
			
			view.free() # !!!! agressive freeing of viewport, orphaned viewports would all run in parallel :scream:
			break
		image_data.unlock()
		yield(get_tree(), "idle_frame")

func _on_MoveHandle_button_down():
	modifier_parent.start_drag(get_parent()) #get parent here is hacky + assumes we're wrapped.. okay iguess

func _on_MoveHandle_button_up():
	modifier_parent.end_drag()
