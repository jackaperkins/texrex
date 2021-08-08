extends PanelContainer

var original_image = null
var image:Image = null

signal image_loaded(image)
signal save_image(path)

onready var file_name_label = $MarginContainer/VBoxContainer/CropContainer/FileLabel
onready var file_stats_label = $MarginContainer/VBoxContainer/CropContainer/FileStatsLabel

var open_file_dialog
var save_file_dialog

export var canvas_path:NodePath
var canvas

func _ready():
	canvas = get_node(canvas_path)
	original_image = Image.new()
	image = Image.new()
	open_file_dialog = get_node("/root/OpenFileDialog")
	save_file_dialog = get_node("/root/SaveFileDialog")
	
	open_file_dialog.connect("file_selected", self, "_on_open_image")
	pass 

func _on_Load_pressed():
	var path = get_saved_path()
	if path != '':
		open_file_dialog.current_dir = path
	open_file_dialog.popup_centered_clamped(Vector2(800,600))

func _on_open_image(path_to_image):
	save_saved_path(path_to_image)
	file_name_label.text = path_to_image
	print("loading new image from path " + path_to_image)
	original_image.load(path_to_image)
	image.copy_from(original_image)
	
	var image_size = image.get_size()
	file_stats_label.text = 'Original Size ' + String(image_size.x) + 'x' + String(image_size.y)
	
	emit_signal("image_loaded", image)

func _on_Save_pressed():
	var path = get_saved_path()
	if path != '':
		save_file_dialog.current_dir = path
	save_file_dialog.popup_centered_clamped(Vector2(800,600))

func get_saved_path()->String:
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		if config.has_section_key('memory', "last_directory"):
			return config.get_value('memory', 'last_directory')
	return ''

func save_saved_path(new_path):
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err != OK:
		config = ConfigFile.new()
	var path = new_path.rsplit("/", true, 1)[0]
	config.set_value('memory', 'last_directory', path)
	config.save('user://settings.cfg')
	
func _on_save_processed_image(result, path):
	print("back in fielimporter, time to save image!")
	save_saved_path(path)
	result.save_png(path)
