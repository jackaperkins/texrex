extends Button

signal add_modifier(modifier)

onready var modifiers = [
	{'Utility': load('res://modifiers/utility/modifier_utility.tscn')},
	{'Contrast': load('res://modifiers/contrast/modifier_contrast.tscn')},
	{'Pallette': load('res://modifiers/pallette/modifier_pallette.tscn')},
	{'Noise': load('res://modifiers/noise/modifier_noise.tscn')},
	{'Resolution': load('res://modifiers/resolution/modifier_resolution.tscn')},
]


# Called when the node enters the scene tree for the first time.
func _ready():
	for pair in modifiers:
		$PopupMenu.add_item(pair.keys()[0])



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AddModifiers_button_down():
	var pos = Rect2(get_global_rect().position.x, get_global_rect().position.y+rect_size.y, rect_size.x,20)
	$PopupMenu.popup(pos)


func _on_PopupMenu_index_pressed(index):
	emit_signal('add_modifier', modifiers[index].values()[0])
