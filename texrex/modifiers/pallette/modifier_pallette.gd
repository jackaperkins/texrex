extends "res://modifiers/modifier.gd"
onready var mat_simple:ShaderMaterial = load('res://modifiers/pallette/m_render_pallette.tres')
onready var mat_image:ShaderMaterial = load('res://modifiers/pallette/m_render_pallette_from_image.tres')

onready var thumbnail = load('res://modifiers/pallette/thumbnail.tscn')

var mat:ShaderMaterial 

var mode = 0 # 0=simple, 1=from image

## for image mode
var pallette_name = ""
var pallette_image:StreamTexture = null

var count = 0
var lerp_amount = 1

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

	var pallette_images = load_pallettes()
	print(String(pallette_images.size()) + ' loaded pallettes!!')
	var first = true
	for item in pallette_images:
		var child = thumbnail.instance()
		$MarginContainer/GridContainer.add_child(child)
		child.pallette = item["pallette"]
		child.pallette_name = item["name"]
		child.refresh()
		child.connect("pallette_picked", self, "_on_pallette_picked")
	
	add_primary_child($Pallette)
	add_primary_child($mode)
	add_secondary_child($LerpContainer)
	add_secondary_child($MarginContainer)
	
	
	_update_ui()


func process_image(incoming:Image):
	if mode == 0 or mode == 1:
		mat_simple.set_shader_param('count', count)
		mat_simple.set_shader_param('dither', mode == 1)
		mat = mat_simple
		# required to feed our image into a shadermaterial and get it back!
	elif mode == 2:
		mat_image.set_shader_param('lerp', lerp_amount)
		mat = mat_image
	var image_texture:ImageTexture = ImageTexture.new()
	image_texture.create_from_image(incoming)
	mat.set_shader_param('tex', image_texture)
	
	yield(process_shader(mat, incoming.get_size(), image), 'completed')
	needs_processing = false

func _on_pallette_picked (new_image, new_name):
	print('new pallette picked')
	mat_image.set_shader_param('sourcePallette', new_image)
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
	pallette.visible = (mode != 2)
	if mode == 0:
		pallette.max_value = 256
	elif mode == 1:
		pallette.value = min(pallette.value,8)
		pallette.max_value = 8
	elif mode > 1:
		_on_show_toggled(true)

	_update_ui()
	needs_processing = true
	emit_signal('updated')
	
	
# load all image files we find in the /textures/pallettes directory
# not sure this will work on all platforms
# https://godotengine.org/qa/59637/cannot-traverse-asset-directory-in-android
func load_pallettes():
	var dir = Directory.new()
	var pallette_list = []
	if dir.open("res://textures/pallettes") == OK:
		dir.list_dir_begin()
		var filename = dir.get_next()
		while (filename != ""):
			if filename.ends_with(".png"):
				pallette_list.append("res://textures/pallettes/" + filename)
			filename = dir.get_next()
			
	print('found pallettes: ' + String(pallette_list.size()))
	
	for x in range(pallette_list.size()):
		var loaded_tex:StreamTexture = load(pallette_list[x])
		pallette_list[x] = {
			"name": filename_to_name(pallette_list[x]),
			"pallette": loaded_tex
		}
	return pallette_list

func filename_to_name(filename:String):
	filename = filename.rsplit('/',true,1)[1]
	filename = filename.rsplit('.')[0]
	filename = filename.replace('_', ' ')
	filename = filename.replacen('pallette', '')
	return filename


func _on_Lerp_value_changed(value):
	lerp_amount = value
	needs_processing = true
	emit_signal('updated')
