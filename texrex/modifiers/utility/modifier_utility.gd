extends Modifier
onready var mat:ShaderMaterial = load('res://modifiers/utility/m_render_utility.tres')

var invert:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	mat = mat.duplicate()
	set_label("Utility")
	add_primary_child($Invert)
	hide_secondary_toggle()

func process_image(incoming:Image):
	mat.set_shader_param('invert', invert)
	# required to feed our image into a shadermaterial and get it back!
	var image_texture:ImageTexture = ImageTexture.new()
	image_texture.create_from_image(incoming)
	mat.set_shader_param('tex', image_texture)
	
	yield(process_shader(mat, incoming.get_size(), image), 'completed')
	needs_processing = false



func _on_Invert_toggled(button_pressed):
	invert = button_pressed
	needs_processing = true
	emit_signal('updated')
