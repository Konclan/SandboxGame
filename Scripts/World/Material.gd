@tool
class_name BMaterial extends Resource

@export var id: String: get = _get_id, set = _set_id
@export var texture: Texture2D

func _get_id() -> String:
	return id

func _set_id(value) -> void:
	if not value.begins_with("mat_"):
		value = "mat_" + value
	id = value.to_snake_case().to_lower()
