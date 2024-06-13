extends Control

@export var editor_scene: String

func _on_button_pressed():
	change_scene(editor_scene)
	
func change_scene(new_scene):
	get_tree().change_scene_to_file(new_scene)
