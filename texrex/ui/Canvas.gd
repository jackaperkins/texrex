extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var canvas_root = $CanvasLayer/canvas_root
onready var canvasScaler = $CanvasLayer/canvas_root/canvasScaler
onready var canvasMainTexture = $CanvasLayer/canvas_root/canvasScaler/GridContainer/MainTexture
onready var canvasAllTextures = $CanvasLayer/canvas_root/canvasScaler/GridContainer.get_children()
onready var bottom_info = $BottomBar/HBoxContainer/BottomInfo

var mostRecentTexture = null

# pan canvas
var is_panning = false

var show_tiles = true

func _ready():
	pass

func set_texture(tex):
	mostRecentTexture = tex
	display_tiles()
		
func _process(delta):
	if Input.is_action_just_pressed('middle_mouse'):
		is_panning = true
	elif Input.is_action_just_released('middle_mouse'):
		is_panning = false

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			canvasScaler.rect_scale += Vector2(0.1, 0.1)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			canvasScaler.rect_scale-= Vector2(0.1, 0.1)
	if event is InputEventMouseMotion:
		if is_panning:
			canvas_root.rect_position += event.relative

func _on_Timer_timeout():
	bottom_info.text = 'memory ' + String(OS.get_static_memory_usage()/1048576) + ' MB'

func display_tiles():
	for t in canvasAllTextures:
		if show_tiles:
			t.texture = mostRecentTexture
		else:
			t.texture = null
	canvasMainTexture.texture = mostRecentTexture
	
func _on_Tile_toggled(button_pressed):
	show_tiles = button_pressed
	display_tiles()
