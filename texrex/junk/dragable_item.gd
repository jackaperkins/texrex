extends PanelContainer

onready var label = $MarginContainer/VBoxContainer/Label
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (Color, RGBA) var color = Color(1, 0, 0, 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = String(floor(rand_range(0,99)))
	if randf() > 0.5:
		var x = label.duplicate()
		$MarginContainer/VBoxContainer.add_child(x)


func can_drop_data(position, data):
	return get_parent().can_drop_data(position + rect_position, data)

func drop_data(position, data):
	get_parent().drop_data(position, data)

func get_drag_data(position):
	var cpb = ColorPickerButton.new()
	cpb.color = color
	cpb.rect_size = Vector2(50, 10)
	set_drag_preview(cpb)
	var data = {}
	data.self = self
	print('started dragging?')
	return data


func _on_TextureButton_button_down():
	get_parent().start_drag(self)
	pass # Replace with function body.


func _on_TextureButton_button_up():
	get_parent().end_drag()
	pass # Replace with function body.
