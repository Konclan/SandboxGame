extends Node3D
class_name Chunk

var blocks := Node3D.new()
var blocks_array := []

var StaticBody := StaticBody3D.new()
var MeshInstance := MeshInstance3D.new()
var CollisionShape := CollisionShape3D.new()

@onready var world = $"../.."
var chunk_size: Vector3

func _ready():
	chunk_size = world.CHUNK_SIZE
	blocks_array.resize(world.to_yzx_order(chunk_size))
	
	add_child(blocks)
	blocks.name = "Blocks"
	add_child(StaticBody)
	StaticBody.add_child(MeshInstance)
	StaticBody.add_child(CollisionShape)

func set_block(pos: Vector3, type: int):
	var offset = pos - position
	var index = world.to_yzx_order(offset)
	var block = blocks_array[index]
	
	if type > 0 and not block:
		var new_block = Block.new()
		new_block.position = pos
		blocks.add_child(new_block)
		new_block.name = str("block",index)
		blocks_array[index] = new_block
	elif block and not type > 0:
		block.queue_free()
		blocks_array[index] = null
		
func get_block(pos):
	var index = world.to_yzx_order(snap_to_chunk(pos))
	var block = blocks_array[index]
	return block

func snap_to_chunk(pos):
	return Vector3(fmod(pos.x, chunk_size.x), fmod(pos.y, chunk_size.y), fmod(pos.z, chunk_size.z))

func is_solid(pos):
	var offset = snap_to_chunk(pos)
	var index = world.to_yzx_order(offset)
	var block = blocks_array[index]
	if block: return true
	return false

func is_empty(pos):
	return not is_solid(pos)
