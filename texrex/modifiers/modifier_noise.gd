extends "res://modifiers/modifier.gd"
onready var mat:ShaderMaterial = load('res://shaders/m_render_noise.tres')
onready var override_tex:Texture = load('res://icons/texrex_icon_4xscaled.png')
var scale = 0.05

# Called when the node enters the scene tree for the first time.
func _ready():
	clear_placeholders()
	add_primary_child($Noise)
	set_label('Noise ' + String(scale))
	
	mat = mat.duplicate()
	mat.set_shader_param('tex', override_tex)
	
	var tabs = $Tabs
	tabs.add_tab("Rainbow")
	tabs.add_tab("Hue Shift")
	add_secondary_child(tabs)
	add_secondary_child($HSlider)
	set_secondary_visible(false)
	

func process_image(incoming:Image):
	print('about to shader process... noise:')
	
	mat.set_shader_param('amount', scale)
	
	# required to feed our image into a shadermaterial and get it back!
	var image_texture:ImageTexture = ImageTexture.new()
	image_texture.create_from_image(incoming)
	mat.set_shader_param('tex', image_texture)
	
	yield(process_shader(mat, incoming.get_size(), image), 'completed')
	print('finished after yield!')
	needs_processing = false
	return


func _on_Noise_value_changed(value):
	scale = pow(value, 4)
	needs_processing = true
	set_label('Noise ' + String(scale))
	emit_signal("updated")
