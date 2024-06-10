extends Control
class_name Interface

var save_path = "user://variable.save"
var textbox_text := ""
var moused := false

@onready var debug_text = $DebugText

@onready var textbox = $AreaTop/LineEdit
@onready var button_save = $AreaTop/GridContainer/SaveButton
@onready var button_load = $AreaTop/GridContainer/LoadButton
@onready var button_tool_block = $AreaBottom/ToolsContainer/ToolBlock
@onready var button_tool_face = $AreaBottom/ToolsContainer/ToolFace
@onready var ui_items = [textbox, button_save, button_load, button_tool_block, button_tool_face]

# Called when the node enters the scene tree for the first time.
func _ready():
	for item in ui_items:
		item.connect('mouse_entered', mouse_entered)
		item.connect('mouse_exited', mouse_exited)
	
func mouse_over_ui():
	return moused

func mouse_entered():
	#print("mouse entered")
	moused=true

func mouse_exited():
	#print("mouse exited")
	moused=false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	textbox_text = textbox.text
	var viewport = get_viewport()
	debug_text.text = str(viewport.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_PRIMITIVES_IN_FRAME))

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

