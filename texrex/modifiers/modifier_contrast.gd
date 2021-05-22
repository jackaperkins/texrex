extends "res://modifiers/modifier.gd"

var contrast = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	contrast = $Contrast.value
	_update_ui()
	
func _process(delta):
	._process(delta)
	

func _update_ui():
	$Label.text = 'Contrast ' + String(contrast)

func process_image(incoming:Image):
	image.copy_from(incoming)
	image.lock()
	for x in range(image.get_width()):
		for y in range(image.get_height()):
			var pixel:Color = image.get_pixel(x,y)
			if pixel.v < 0.5:
				pixel = pixel.darkened(contrast)
			else:
				pixel = pixel.lightened(contrast)
			image.set_pixel(x,y, pixel)
	image.unlock()
	
	
	print('processing contrast!')
	needs_processing = false

func _on_Contrast_value_changed(value):
	contrast = value
	print('contrast changed in modifier')
	_update_ui()
	needs_processing = true
	emit_signal('updated')

