extends Button

signal add_modifier(modifier)

var separators = 0

onready var modifiers = [
		{'-': 'Core'},
		{'Resolution': load('res://modifiers/resolution/modifier_resolution.tscn')},
		{'Utility': load('res://modifiers/utility/modifier_utility.tscn')},
		{'-': 'Color'},
		{'Contrast': load('res://modifiers/contrast/modifier_contrast.tscn')},
		{'Pallette': load('res://modifiers/pallette/modifier_pallette.tscn')},
		{'-': 'Detail'},
		{'Blur': load('res://modifiers/blur/modifier_blur.tscn')},
		{'Noise': load('res://modifiers/noise/modifier_noise.tscn')},
		{'-': 'Layout'},
		
		{'Seamless': load('res://modifiers/seamless/modifier_seamless.tscn')}
	]



# Called when the node enters the scene tree for the first time.
func _ready():
	
	for m in modifiers:
		if m.keys()[0] == '-':
			$PopupMenu.add_separator(m.values()[0])
		else:
			$PopupMenu.add_item(m.keys()[0])
	



func _on_AddModifiers_button_down():
	var pos = Rect2(get_global_rect().position.x, get_global_rect().position.y+rect_size.y, rect_size.x,20)
	$PopupMenu.popup(pos)


func _on_PopupMenu_index_pressed(index):
	emit_signal('add_modifier', modifiers[index].values()[0])
