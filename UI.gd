extends Control

var save_path = "user://variable.save"
var textbox_text := ""

@onready var textbox = $LineEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	textbox_text = textbox.text

func save_data():
	var file = FileAccess.open(save_path,FileAccess.WRITE)
	file.store_var(textbox_text)
	print("Data saved.")

func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		textbox.text = file.get_var()
		print("Data loaded")
	else:
		print("No Data loaded")

func _on_save_button_pressed():
	save_data()

func _on_load_button_pressed():
	load_data()
