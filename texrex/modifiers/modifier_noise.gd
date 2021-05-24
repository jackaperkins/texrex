extends "res://modifiers/modifier.gd"

var scale = 0.05

# Called when the node enters the scene tree for the first time.
func _ready():
	clear_placeholders()
	set_secondary_visible(false)
	add_primary_child($LineEdit)

func process_image(incoming:Image):
	image.copy_from(incoming)
	image.lock()
	for x in range(image.get_width()):
		for y in range(image.get_height()):
			var pixel:Color = image.get_pixel(x,y)
			pixel.r += rand_range(-1,1)*scale
			pixel.g += rand_range(-1,1)*scale
			pixel.b += rand_range(-1,1)*scale
			image.set_pixel(x,y, pixel)
	image.unlock()
	
	
	print('processing contrast!')
	needs_processing = false


func _on_show_toggled(button_pressed):
	print('calling toggle in base')
	._on_show_toggled(button_pressed)
