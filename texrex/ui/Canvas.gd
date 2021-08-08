extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var canvas_root = $CanvasLayer/canvas_root
onready var canvasScaler = $CanvasLayer/canvas_root/canvasScaler
onready var canvasMainTexture = $CanvasLayer/canvas_root/canvasScaler/GridContainer/MainTexture
onready var canvasAllTextures = $CanvasLayer/canvas_root/canvasScaler/GridContainer.get_children()
onready var bottom_info = $BottomBar/HBoxContainer/BottomInfo

onready var scale_label = $BottomBar/HBoxContainer/HBoxContainer/ScaleLabel

var mostRecentTexture = null

# pan canvas
var is_panning = false

var show_tiles = true

func _ready():
	frame_center()
	pass

func set_texture(tex):
	print('setting texture in canvas')
	mostRecentTexture = tex
	display_tiles()
	
func frame_center():
	canvas_root.rect_position = rect_size / 2
	pass
		
func _process(delta):
	if Input.is_action_just_pressed('middle_mouse'):
		is_panning = true
	elif Input.is_action_just_released('middle_mouse'):
		is_panning = false

func _input(event):
	# bug this is doubled for some reason
	if event is InputEventMouseButton:
		if not get_global_rect().has_point(get_viewport().get_mouse_position()):
			return
		var next_scale = canvasScaler.rect_scale.x
		if event.button_index == BUTTON_WHEEL_UP:
			if next_scale >= 1:
				next_scale += .2
			else:
				next_scale += .05
		elif event.button_index == BUTTON_WHEEL_DOWN:
			if next_scale > 1:
				next_scale -= .2
			else:
				next_scale -= .05
		
		if event.button_index == BUTTON_WHEEL_UP or event.button_index == BUTTON_WHEEL_DOWN:
			next_scale = clamp(next_scale, 0, 5)
			canvasScaler.rect_scale = Vector2(next_scale,next_scale)
			scale_label.text = "Scale " + String(int(next_scale*100)) + "%"
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


func _on_ResetView_pressed():
	frame_center()
	scale_label.text = "Scale 100%"
	canvasScaler.rect_scale = Vector2(1,1)

