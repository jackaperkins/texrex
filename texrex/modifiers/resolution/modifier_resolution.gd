extends "res://modifiers/modifier.gd"

var power = 3
var interpolate = false

onready var interpolate_control = $Interpolate

# Called when the node enters the scene tree for the first time.
func _ready():
	power = $Resolution.value
	add_primary_child($Resolution)
	add_primary_child($Interpolate)
	_update_ui()
	hide_secondary_toggle()
	
func _update_ui():
	set_label('Resolution ' + String(pow(2,power)) + 'x' + String(pow(2,power)))

func process_image(incoming:Image):
	image.copy_from(incoming)
	var size = pow(2, power)
	if interpolate:
		# morally fraught option
		image.resize(size,size, Image.INTERPOLATE_BILINEAR)
	else:
		image.resize(size,size, Image.INTERPOLATE_NEAREST)
	needs_processing = false

func _on_Resolution_value_changed(value):
	power = value
	_update_ui()
	needs_processing = true
	emit_signal('updated')


func _on_Interpolate_toggled(button_pressed):
	if button_pressed:
		interpolate_control.text = "Interpolate (morally incorrect option)"
	else:
		interpolate_control.text = "Interpolate"
	interpolate = button_pressed
	needs_processing = true
	emit_signal('updated')
