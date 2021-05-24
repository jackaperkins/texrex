extends Control

signal updated()
var needs_processing = false # flag value

var image = Image.new()
var modulate_color
var glow = 0


func _process(delta):
	if glow > 0:
		glow = clamp(glow-delta, 0, 1)

func process_image(incoming:Image):
	pass

func add_primary_child(node:Node):
	node.get_parent().remove_child(node)
	$Main/Primary.add_child(node)

# Called when the node enters the scene tree for the first time.
func _ready():
	modulate_color = self_modulate
	pass # Replace with function body.


func _on_show_toggled(button_pressed):
	$Main/Secondary.visible = button_pressed
