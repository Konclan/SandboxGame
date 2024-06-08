extends Node3D
class_name Voxels

const GRID_SIZE = 1
const GRID = Vector3(GRID_SIZE, GRID_SIZE, GRID_SIZE)

@onready var Blocks = $Blocks

func block_tool_place(trace):
	var pos = (trace.position + ((trace.normal * GRID_SIZE) * 0.6)).snapped(GRID)
	if is_empty(pos):
		place_block(pos)

func block_tool_remove(trace):
	var block = trace.collider
	remove_block(block)

func face_tool_color(trace, color):
	set_face_color(trace, color)
	
func face_tool_texture(trace, texture):
	set_face_texture(trace, texture)

func place_block(pos):
	var block_new = VoxelBlock.new()
	block_new.position = pos
	Blocks.add_child(block_new)

func remove_block(block):
	if block is VoxelBlock:
		block.queue_free()

func set_face_color(cast, color):
	if cast.collider is VoxelBlock:
		cast.collider.modify_voxel_face_color(cast.normal, color)

func set_face_texture(cast, texture):
	if cast.collider is VoxelBlock:
		var material = StandardMaterial3D.new()
		material.albedo_texture = texture
		material.texture_filter = 0
		material.cull_mode = 0
		material.vertex_color_use_as_albedo = true
		cast.collider.modify_voxel_face_material(cast.normal, material)

func is_empty(pos):
	var point_query = PhysicsPointQueryParameters3D.new()
	var space = get_world_3d().direct_space_state
	point_query.position = pos
	point_query.collide_with_areas = false
	point_query.collide_with_bodies = true
	var intersections = space.intersect_point(point_query)
	for result in intersections:
		if is_instance_valid(result.collider):
			if result.collider is VoxelBlock:
				return false
	return true
