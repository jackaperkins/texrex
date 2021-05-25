extends "res://modifiers/modifier.gd"
onready var mat:ShaderMaterial = load('res://shaders/m_render_noise.tres')

var scale = 0.05
var mode = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	clear_placeholders()
	add_primary_child($Noise)
	set_label('Noise ' + String(scale))
	
	mat = mat.duplicate()
	
	var tabs = $Mode
	tabs.add_tab("Brightness")
	tabs.add_tab("Hue Shift")
	tabs.add_tab("Rainbow")
	add_secondary_child(tabs)
	

func process_image(incoming:Image):
	mat.set_shader_param('amount', scale)
	mat.set_shader_param('mode', mode)
	
	# required to feed our image into a shadermaterial and get it back!
	var image_texture:ImageTexture = ImageTexture.new()
	image_texture.create_from_image(incoming)
	mat.set_shader_param('tex', image_texture)
	
	yield(process_shader(mat, incoming.get_size(), image), 'completed')
	needs_processing = false


func _on_Noise_value_changed(value):
	scale = pow(value, 4)
	needs_processing = true
	set_label('Noise ' + String(scale))
	emit_signal("updated")


func _on_Mode_tab_changed(tab):
	mode = tab
	needs_processing = true
	emit_signal("updated")
