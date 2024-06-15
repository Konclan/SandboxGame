extends Node3D
class_name Chunk

var blocks := Node3D.new()
var blocks_array := []

var StaticBody := StaticBody3D.new()
var MeshInstance := MeshInstance3D.new()
var CollisionShape := CollisionShape3D.new()

@onready var world = $"../.."

var bitboards: Array
var chunk: Dictionary

func _ready():
	var chunk_size = world.CHUNK_SIZE
	blocks_array.resize(chunk_size.y * 256 + chunk_size.z * 16 + chunk_size.x)
	
	add_child(blocks)
	blocks.name = "Blocks"
	add_child(StaticBody)
	StaticBody.add_child(MeshInstance)
	StaticBody.add_child(CollisionShape)
	
	for c in range(chunk_size.y):
		var bitboard := BitMap.new()
		bitboard.create(Vector2i(chunk_size.x, chunk_size.z))
		bitboards.append(bitboard)

func set_block(pos: Vector3, type: int):
	var offset = pos - position
	
	var bitboard = bitboards[offset.y]
	var bit_pos = Vector2i(offset.x, offset.z)
	
	if bit_pos > bitboard.get_size(): printerr("set_block: Pos ", bit_pos, " out of range! ", bitboard.get_size()); return
	
	var prev_bit = bitboard.get_bit(bit_pos.x, bit_pos.y)
	var bit = true if type > 0 else false
	bitboard.set_bit(bit_pos.x, bit_pos.y, bit)
	
	var index = world.to_yzx_order(pos)
	
	if bit and not prev_bit:
		var block = Block.new()
		block.position = pos
		blocks.add_child(block)
		block.name = str("block",index)
		blocks_array[index] = block
	elif not bit and prev_bit:
		var block = get_block(pos)
		if block:
			block.queue_free()
			blocks_array[index] = null
		
func get_block(pos):
	var index = world.to_yzx_order(pos)
	return blocks_array[index]

func is_solid(pos):
	var offset = pos - position
	
	var bitboard = bitboards[offset.y]
	var bit_pos = Vector2i(offset.x, offset.z)
	if bit_pos > bitboard.get_size(): printerr("get_chunk_data: Pos ", bit_pos, " out of range! ", bitboard.get_size()); return
	return bitboard.get_bit(bit_pos.x, bit_pos.y)

func is_empty(pos):
	return not is_solid(pos)
