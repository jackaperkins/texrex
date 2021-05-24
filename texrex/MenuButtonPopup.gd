extends MenuButton

var popup

func _ready():
	popup = get_popup()
	popup.add_item("Open...")
	popup.add_separator()
	popup.add_item("item b")
	popup.add_item("item c")
	popup.connect("id_pressed", self, "_on_item_pressed")

func _on_item_pressed(ID):
	print(ID)
	print(popup.get_item_text(ID), " pressed")
