extends Node3D
class_name PlayerInteraction

const RANGE = 20

@onready var scene = get_tree().current_scene
@onready var pointer = get_node("../Pointer")
@onready var interface = get_node("../Interface")
@onready var voxels = get_node("../../Voxels")

var brick_texture = load("res://Assets/Textures/brick.png")
var concrete_texture = load("res://Assets/Textures/concrete_floor.png")
var default_texture = load("res://Assets/Textures/default_arrows.png")

var tool := String("")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	var cursor_raycast = get_cursor_pos_3d()
	
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		if Input.is_action_just_pressed("primary_action"):
			primary_action(cursor_raycast)

		if Input.is_action_just_pressed("secondary_action"):
			secondary_action(cursor_raycast)
	
	if cursor_raycast:
		pointer.visible = true
		var target_position = cursor_raycast.position
		var target_normal = cursor_raycast.normal
		var new_position = target_position + (1 * target_normal)
	
		pointer.position = new_position
		
		if not pointer.position.is_equal_approx(target_position):
			if target_normal.is_equal_approx(Vector3.UP):
				pointer.rotation = Vector3(deg_to_rad(-90), 0, 0)
			elif target_normal.is_equal_approx(Vector3.DOWN):
				pointer.rotation = Vector3(deg_to_rad(90), 0, 0)
			else:
				pointer.look_at(target_position)
	else:
		pointer.visible = false

func primary_action(cast):
	if cast:
		match tool:
			"ToolBlock":
				voxels.block_tool_place(cast)
			"ToolFace":
				voxels.face_tool_texture(cast, brick_texture)


func secondary_action(cast):
	if cast:
		match tool:
			"ToolBlock":
				voxels.block_tool_remove(cast)
			"ToolFace":
				voxels.face_tool_texture(cast, concrete_texture)

func get_cursor_pos_3d():
	if interface.moused:
		return
	var viewport = scene.get_viewport()
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


func _on_tool_block_pressed():
	tool = "ToolBlock"


func _on_tool_face_pressed():
	tool = "ToolFace"
