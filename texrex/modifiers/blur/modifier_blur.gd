extends Modifier

onready var mat = load('res://modifiers/blur/m_render_blur.tres')

# Called when the node enters the scene tree for the first time.
func _ready():
	mat = mat.duplicate()
	update_ui()

func update_ui():
	set_label("Blur")

func process_image(incoming:Image):
	# required to feed our image into a shadermaterial and get it back!
	var image_texture:ImageTexture = ImageTexture.new()
	image_texture.create_from_image(incoming)
	mat.set_shader_param('tex', image_texture)
	
	yield(process_shader(mat, incoming.get_size(), image), 'completed')
	needs_processing = false
