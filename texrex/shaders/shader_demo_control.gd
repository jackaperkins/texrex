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
	
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	var texture = view.get_texture()
	var image = texture.get_data()
	tex.create_from_image(image)
	$TextureRect.texture = tex
