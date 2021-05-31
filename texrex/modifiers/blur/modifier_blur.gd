extends Modifier

onready var mat = load('res://modifiers/blur/m_render_blur.tres')

var amount = 0
var smart = false

# Called when the node enters the scene tree for the first time.
func _ready():
	mat = mat.duplicate()
	add_primary_child($Amount)
	add_primary_child($Smart)
	update_ui()
	hide_secondary_toggle()

func update_ui():
	set_label("Blur")

func process_image(incoming:Image):
	# required to feed our image into a shadermaterial and get it back!
	mat.set_shader_param('amount', amount)
	mat.set_shader_param('smart', smart)
	var image_texture:ImageTexture = ImageTexture.new()
	image_texture.create_from_image(incoming)
	mat.set_shader_param('tex', image_texture)
	
	yield(process_shader(mat, incoming.get_size(), image), 'completed')
	needs_processing = false


func _on_Amount_value_changed(value):
	amount = value
	needs_processing = true
	emit_signal('updated')

func _on_Smart_toggled(button_pressed):
	smart = button_pressed
	needs_processing = true
	emit_signal('updated')
