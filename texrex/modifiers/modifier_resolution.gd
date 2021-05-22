extends "res://modifiers/modifier.gd"

var power = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	power = $Resolution.value
	_update_ui()
	
func _update_ui():
	$Label.text = 'Resolution ' + String(pow(2,power))

func process_image(incoming:Image):
	image.copy_from(incoming)
	image.lock()
#	image.set_pixel(rand_range(3,30),30, Color(0,0,0.0))
#	image.set_pixel(rand_range(3,30),32, Color(0,0,1.0))
	image.unlock()
	var size = pow(2, power)
	image.resize(size,size, Image.INTERPOLATE_NEAREST)
	needs_processing = false

func _on_Resolution_value_changed(value):
	power = value
	print('resolution changed in modifier')
	_update_ui()
	needs_processing = true
	emit_signal('updated')

