extends "res://modifiers/modifier.gd"

var count

# Called when the node enters the scene tree for the first time.
func _ready():
	count = $Pallette.value
	_update_ui()
	
func _update_ui():
	$Label.text = 'Pallette ' + String(count)

func process_image(incoming:Image):
	image.copy_from(incoming)
	image.lock()
	for x in range(image.get_width()):
		for y in range(image.get_height()):
			var pixel:Color = image.get_pixel(x,y)
			pixel.r = floor(pixel.r*count) / float(count)
			pixel.g = floor(pixel.g*count) / float(count)
			pixel.b = floor(pixel.b*count) / float(count)
			image.set_pixel(x,y, pixel)
	image.unlock()
	
	needs_processing = false

func _on_Resolution_value_changed(value):
	count = value
	print('pallette changed in modifier')
	_update_ui()
	needs_processing = true
	emit_signal('updated')

