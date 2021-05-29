extends "res://modifiers/modifier.gd"
onready var mat_simple:ShaderMaterial = load('res://modifiers/pallette/m_render_pallette.tres')
onready var mat_image:ShaderMaterial = load('res://modifiers/pallette/m_render_pallette_from_image.tres')

var mat:ShaderMaterial 

var mode = 0 # 0=simple, 1=from image

## for image mode
var pallette_name = ""
var pallette_image:StreamTexture = null

var count = 0
var dither = false

var pallette:HSlider

# Called when the node enters the scene tree for the first time.
func _ready():
	pallette = $Pallette
	count = pallette.value
	mat_simple = mat_simple.duplicate()
	mat_image = mat_image.duplicate()
	set_secondary_visible(false)
	
	$mode.add_tab("Simple")
	$mode.add_tab("Dither")
	$mode.add_tab("Pallette")

	
	
	var first = true
	for child in $MarginContainer/GridContainer.get_children():
		child.connect("pallette_picked", self, "_on_pallette_picked")
		if first:
			first = false
			mat_image.set_shader_param('sourcePallette', child.pallette)
			pallette_name = child.pallette_name
	
	add_primary_child($Pallette)
	add_primary_child($mode)
	add_secondary_child($MarginContainer)
	
	_update_ui()


func process_image(incoming:Image):
	if mode == 0 or mode == 1:
		mat_simple.set_shader_param('count', count)
		mat_simple.set_shader_param('dither', mode == 1)
		mat = mat_simple
		# required to feed our image into a shadermaterial and get it back!
	elif mode == 2:
		mat = mat_image
	var image_texture:ImageTexture = ImageTexture.new()
	image_texture.create_from_image(incoming)
	mat.set_shader_param('tex', image_texture)
	
	yield(process_shader(mat, incoming.get_size(), image), 'completed')
	needs_processing = false

func _on_pallette_picked (pallette, new_name):
	print('new pallette picked')
	mat_image.set_shader_param('sourcePallette', pallette)
	pallette_name = new_name
	_update_ui()
	needs_processing = true
	emit_signal('updated')

func _update_ui():
	if mode < 2:
		set_label('Pallette ' + String(count))
	elif mode == 2:
		set_label('Pallette ' + pallette_name)

func _on_Pallette_value_changed(value):
	count = value
	print('pallette changed in modifier')
	_update_ui()
	needs_processing = true
	emit_signal('updated')

func _on_mode_tab_changed(tab):
	mode = tab
	if mode == 1:
		pallette.value = min(pallette.value,8)
	if mode > 1:
		_on_show_toggled(true)
	_update_ui()
	needs_processing = true
	emit_signal('updated')
