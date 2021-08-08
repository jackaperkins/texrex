# fuck unity
extends Control

onready var modifier_stack = $main_split/ModifierStack
onready var canvas = $"main_split/main area/VBoxContainer/canvas"
onready var about_popup = $AboutPopup


func _on_AboutButton_pressed():
	about_popup.popup()

func _ready():
	modifier_stack.connect("image_processed", canvas, "set_image")
