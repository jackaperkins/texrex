extends "res://modifiers/modifier.gd"

var power = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	power = $Resolution.value
	add_primary_child($Resolution)
	_update_ui()
	hide_secondary_toggle()
	
func _update_ui():
	set_label('Resolution ' + String(pow(2,power)) + 'x' + String(pow(2,power)))

func process_image(incoming:Image):
	image.copy_from(incoming)
	var size = pow(2, power)
	image.resize(size,size, Image.INTERPOLATE_NEAREST)
	needs_processing = false

func _on_Resolution_value_changed(value):
	power = value
	_update_ui()
	needs_processing = true
	emit_signal('updated')

