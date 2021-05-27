extends VBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var preview_bar = $"../PreviewBar"

var potential_index = 0

var dragging = false
var dragging_node = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _input(event):
	if not dragging:
		return
	if event is InputEventMouseMotion:
		potential_index = 0
		var position = event.position
#		position.y = floor(position.y / 40)*40
		
		var children = get_children()
		
		var snapped_y = 0
		
		# loop over children comparing out height to half middle of each child
		for child in children:
			if position.y < child.get_global_rect().position.y + child.rect_size.y/2:
				break
			else:
				potential_index += 1
				snapped_y = child.rect_position.y + child.rect_size.y

		preview_bar.rect_position = Vector2(0, snapped_y)

func start_drag (node):
	dragging_node = node
	dragging = true
	pass
	
func end_drag():
	dragging = false
	move_child(dragging_node, potential_index)
	print(potential_index)
