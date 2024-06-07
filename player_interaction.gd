extends Node3D
class_name PlayerInteraction

const GRID_SIZE = 1
const GRID = Vector3(GRID_SIZE, GRID_SIZE, GRID_SIZE)
const BLOCK = preload("res://Voxels/Blocks/block.tscn")
const RANGE = 20

@onready var scene = get_tree().current_scene
@onready var blocks = get_node("../../Voxels/Blocks")
@onready var pointer = get_node("../Pointer")
@onready var interface = get_node("../Interface")

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
				var pos = (cast.position + ((cast.normal * GRID_SIZE) * 0.6)).snapped(GRID)
				if is_empty(pos):
					place_block(pos)
			"ToolFace":
				set_face_color(cast, Color.BLACK)


func secondary_action(cast):
	if cast:
		match tool:
			"ToolBlock":
				var object = cast.collider
				remove_block(object)
			"ToolFace":
				set_face_color(cast, Color.WHITE)

func place_block(pos):
	var block_new = BLOCK.instantiate()
	block_new.position = pos
	blocks.add_child(block_new)

func remove_block(block):
	if block is VoxelBlock:
		block.queue_free()

func set_face_color(cast, color):
	if cast.collider is VoxelBlock:
		cast.collider.modify_voxel(color)

func is_empty(pos):
	var point_query = PhysicsPointQueryParameters3D.new()
	var space = get_world_3d().direct_space_state
	point_query.position = pos
	point_query.collide_with_areas = false
	point_query.collide_with_bodies = true
	point_query.exclude = [self]
	var result = space.intersect_point(point_query)
	if is_instance_valid(result):
		return result is VoxelBlock
	else:
		return true

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
