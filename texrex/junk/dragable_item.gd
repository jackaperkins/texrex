extends PanelContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (Color, RGBA) var color = Color(1, 0, 0, 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/Label.text = String(floor(rand_range(0,99)))
	if randf() > 0.5:
		var x = $VBoxContainer/Label2.duplicate()
		$VBoxContainer.add_child(x)
	$VBoxContainer/ColorPickerButton.color = Color(randf(), randf(), randf())


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
