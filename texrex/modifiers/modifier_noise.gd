extends "res://modifiers/modifier.gd"



# Called when the node enters the scene tree for the first time.
func _ready():
	print('noise modifier woke up')
	add_primary_child($LineEdit)

func process_image(incoming:Image):
	pass


func _on_show_toggled(button_pressed):
	print('calling toggle in base')
	._on_show_toggled(button_pressed)
