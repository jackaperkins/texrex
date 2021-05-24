extends Control

class_name Modifier

signal updated()
var needs_processing = false # flag value
var skip = false

var image = Image.new()
var modulate_color
var glow = 0

onready var secondary = $Main/Secondary

# UI stuff
func _process(delta):
	if glow > 0:
		glow = clamp(glow-delta, 0, 1)

func add_primary_child(node:Node):
	node.get_parent().remove_child(node)
	$Main/Primary.add_child(node)

func add_secondary_child(node:Node):
	node.get_parent().remove_child(node)
	$Main/Secondary/VBox.add_child(node)

func clear_placeholders():
	for child in $Main/Primary.get_children():
		child.queue_free()

	for child in $Main/Secondary/VBox.get_children():
		child.queue_free()		

func set_secondary_visible(value):
	$Main/Secondary.visible = value
	$Main/Title/ShowSecondary.pressed = value
	
func hide_secondary_toggle():
	$Main/Secondary.visible = false
	$Main/Title/ShowSecondary.visible = false
	
func set_label(text:String):
	$Main/Title/Label.text = text

# Called when the node enters the scene tree for the first time.
func _ready():
	modulate_color = self_modulate
	pass # Replace with function body.


func _on_show_toggled(button_pressed):
	$Main/Secondary.visible = button_pressed

func _on_skip_toggled(button_pressed):
	print('skip toggled ' + String(button_pressed))
	skip = button_pressed
	needs_processing = true
	emit_signal('updated')

## image processing
func process_image(incoming:Image):
	pass
