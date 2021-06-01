extends Modifier
onready var mat:ShaderMaterial = load('res://modifiers/seamless/m_render_seamless.tres')

var vertical = true
var horizontal = true

# Called when the node enters the scene tree for the first time.
func _ready():
	mat = mat.duplicate()
	set_label("Seamless")
	add_primary_child($Controls)
	hide_secondary_toggle()

func process_image(incoming:Image):
	mat.set_shader_param('vertical', vertical)
	mat.set_shader_param('horizontal', horizontal)
	
	# required to feed our image into a shadermaterial and get it back!
	var image_texture:ImageTexture = ImageTexture.new()
	image_texture.create_from_image(incoming)
	mat.set_shader_param('tex', image_texture)
	
	yield(process_shader(mat, incoming.get_size(), image), 'completed')
	needs_processing = false


func _on_Vertical_toggled(button_pressed):
	vertical = button_pressed
	needs_processing = true
	emit_signal('updated')

func _on_Horizontal_toggled(button_pressed):
	horizontal = button_pressed
	needs_processing = true
	emit_signal('updated')
