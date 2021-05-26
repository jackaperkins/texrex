extends "res://modifiers/modifier.gd"
onready var mat:ShaderMaterial = load('res://modifiers/pallette/m_render_pallette.tres')

var count

# Called when the node enters the scene tree for the first time.
func _ready():
	count = $Pallette.value
	clear_placeholders()
	mat = mat.duplicate()
	set_secondary_visible(false)
	add_primary_child($Pallette)
	hide_secondary_toggle()
	_update_ui()

	
func _update_ui():
	print('updating pallete modifier ui' + String(count))
	set_label('Pallette ' + String(count))

func process_image(incoming:Image):
	mat.set_shader_param('count', count)
	# required to feed our image into a shadermaterial and get it back!
	var image_texture:ImageTexture = ImageTexture.new()
	image_texture.create_from_image(incoming)
	mat.set_shader_param('tex', image_texture)
	
	yield(process_shader(mat, incoming.get_size(), image), 'completed')
	needs_processing = false

func _on_Pallette_value_changed(value):
	count = value
	print('pallette changed in modifier')
	_update_ui()
	needs_processing = true
	emit_signal('updated')
