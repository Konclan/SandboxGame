class_name UserInterface extends Control

@export var _debug_text: RichTextLabel
@export var _user_interaction: UserInteraction
@export var _text_box: LineEdit
@export var _button_save: Button
@export var _button_load: Button
@export var _button_tool_block: Button
@export var _button_tool_face: Button

@onready var _ui_items = [_text_box, _button_save, _button_load, _button_tool_block, _button_tool_face]

var save_path = "user://variable.save"

var _text_box_text := ""
var _moused := false

# Called when the node enters the scene tree for the first time.
func _ready():
	for item in _ui_items:
		item.connect('mouse_entered', _mouse_entered)
		item.connect('mouse_exited', _mouse_exited)
	
func mouse_over_ui():
	return _moused

func _mouse_entered():
	_moused=true

func _mouse_exited():
	_moused=false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	_text_box_text = _text_box.text
	var viewport = get_viewport()
	_debug_text.text = str(viewport.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_PRIMITIVES_IN_FRAME))

func save_data():
	var file = FileAccess.open(save_path,FileAccess.WRITE)
	file.store_var(_text_box_text)
	print("Data saved.")

func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		_text_box.text = file.get_var()
		print("Data loaded")
	else:
		print("No Data loaded")

func _on_save_button_pressed():
	save_data()

func _on_load_button_pressed():
	load_data()

func _on_tool_block_pressed():
	_user_interaction.set_tool("ToolBlock")

func _on_tool_face_pressed():
	_user_interaction.set_tool("ToolFace")
