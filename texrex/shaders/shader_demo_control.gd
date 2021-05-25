extends Control

onready var mat = load('res://shaders/shader_tester_material.tres')

var tex=ImageTexture.new()
var view:Viewport


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	view = Viewport.new()
	view.disable_3d = true
	view.render_target_update_mode = Viewport.UPDATE_ALWAYS
	view.size = Vector2(256,256)
	var rect = ColorRect.new()
	rect.material = mat
	rect.rect_size = Vector2(256,256)
	view.add_child(rect)
	view.render_target_v_flip = true
	add_child(view)
	
	var texture:ViewportTexture
	var image:Image

	# dangerous scary loop where we spin waiting for the texture to render
	while true:
		texture = view.get_texture()
		image = texture.get_data()
		image.lock()
		# we know our texture is done because the pixel in the corner isn't 0 alpha
		if image.get_pixel(0,0).a != 0.0:
			image.unlock()
			break
		image.unlock()
		yield(get_tree(), "idle_frame")
	

	image.lock()
	print(image.get_pixel(0,0))
	image.unlock()
	tex.create_from_image(image)
	$TextureRect.texture = tex
