extends Control

signal pallette_picked(pallette)

export var pallette: Texture
export var pallette_name: String

# Called when the node enters the scene tree for the first time.
func _ready():
	refresh()

func refresh():
	$TextureButton.texture_normal = pallette
	$Label.text = pallette_name

func _on_TextureButton_pressed():
	emit_signal("pallette_picked", pallette, pallette_name)	
