class_name UserInteraction extends Node3D

const RANGE = 20

@onready var _scene = get_tree().current_scene
@export var _player: Player
@export var _pointer: MeshInstance3D
@export var _block_highlight: MeshInstance3D
@export var _user_interface: Control

var tool := String("")
var texture := 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):

	var cursor_raycast = get_cursor_pos_3d()
	
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		if Input.is_action_just_pressed("primary_action"):
			primary_action(cursor_raycast)

		if Input.is_action_just_pressed("secondary_action"):
			secondary_action(cursor_raycast)
	
	if cursor_raycast and cursor_raycast.collider is Chunk:
		_pointer.visible = true
		_block_highlight.visible = true
		var target_position = cursor_raycast.position
		var target_normal = cursor_raycast.normal
		var new_position = target_position + (1 * target_normal)
	
		_pointer.global_position = new_position
		
		if not _pointer.global_position.is_equal_approx(target_position):
			if target_normal.is_equal_approx(Vector3.UP):
				_pointer.rotation = Vector3(deg_to_rad(-90), 0, 0)
			elif target_normal.is_equal_approx(Vector3.DOWN):
				_pointer.rotation = Vector3(deg_to_rad(90), 0, 0)
			else:
				_pointer.look_at(target_position)
				
		var brush_position = (cursor_raycast.position - 0.5 * cursor_raycast.normal).floor()
		
		_block_highlight.global_position = brush_position + Vector3(0.5, 0.5, 0.5)
	else:
		_pointer.visible = false
		_block_highlight.visible = false

func primary_action(cast):
	if cast:
		var brush_position = (cast.position - 0.5 * cast.normal).floor()
		match tool:
			"ToolBlock":
				ChunkManager.instance.set_brush(Vector3i(brush_position), BrushManager.instance.Air)
			"ToolFace":
				ChunkManager.instance.set_brush_texture_face(Vector3i(brush_position), cast.normal, texture)


func secondary_action(cast):
	if cast:
		var brush_position = (cast.position - 0.5 * cast.normal).floor()
		match tool:
			"ToolBlock":
				ChunkManager.instance.set_brush(Vector3i(brush_position + cast.normal), Brush.new())
			"ToolFace":
				pass

func get_cursor_pos_3d():
	if _user_interface.mouse_over_ui():
		return
	var viewport = _scene.get_viewport()
	var camera = viewport.get_camera_3d()
	var mouse_pos = viewport.get_mouse_position()
	var ray_length = RANGE
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	ray_query.collide_with_areas = false
	ray_query.exclude = [self]
	var result = space.intersect_ray(ray_query)
	return result


func set_tool(t: String) -> void:
	tool = t


func set_texture(t: int) -> void:
	texture = t
