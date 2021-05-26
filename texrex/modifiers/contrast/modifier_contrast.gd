extends "res://modifiers/modifier.gd"

onready var mat:ShaderMaterial = load('res://modifiers/contrast/m_render_contrast.tres')

var contrast = 1
var brightness = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	contrast = $Contrast.value
	add_primary_child($Contrast)
	add_primary_child($PostBrightness)
	_update_ui()
	hide_secondary_toggle()
	
func _process(delta):
	._process(delta)

func _update_ui():
	set_label('Contrast ' + String(contrast))

func process_image(incoming:Image):
	mat.set_shader_param('contrast', contrast)
	mat.set_shader_param('brightness', brightness)
	
	# required to feed our image into a shadermaterial and get it back!
	var image_texture:ImageTexture = ImageTexture.new()
	image_texture.create_from_image(incoming)
	mat.set_shader_param('tex', image_texture)
	
	yield(process_shader(mat, incoming.get_size(), image), 'completed')

	needs_processing = false

func _on_Contrast_value_changed(value):
	contrast = value
	_update_ui()
	needs_processing = true
	emit_signal('updated')

func _on_Brightness_value_changed(value):
	brightness = value
	needs_processing = true
	emit_signal('updated')
