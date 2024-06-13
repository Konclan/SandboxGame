extends Node

@export var grid_size := 1
@export var world_size := Vector3(128, 128, 128)
const CHUNK_SIZE := Vector3(16.0, 16.0, 16.0)

var chunks_array = []

@onready var greedy_mesh = $GreedyMesh
@onready var chunks_node = $Chunks

# Define our chunks
func _ready():
	define_chunks()
	
	var chunk_pos := []
	for child in greedy_mesh.get_children():
		if "CubeSpawner" in child.name:
			greedy_mesh.make_solid(child.global_position)
			if not floor(child.global_position/CHUNK_SIZE) in chunk_pos:
				chunk_pos.append(floor(child.global_position/CHUNK_SIZE))
	for pos in chunk_pos:
		var chunk = get_chunk(pos)
		greedy_mesh.greedy_mesh(chunk)

func define_chunks():
	var size = (world_size/CHUNK_SIZE)
	var start_pos = ceil(Vector3(-size.x/2, -size.y/2, -size.z/2));
	for j in range(size.y):
		for k in range(size.z):
			for l in range(size.x):
				var next_pos = start_pos + Vector3(l, j, k)
				var bitboards = []
				for c in range(CHUNK_SIZE.y):
					var bitboard = BitMap.new()
					bitboard.create(Vector2i(CHUNK_SIZE.x, CHUNK_SIZE.z))
					bitboards.append(bitboard)
					
				var StaticBody := StaticBody3D.new()
				var MeshInstance := MeshInstance3D.new()
				var CollisionShape := CollisionShape3D.new()
				
				chunks_node.add_child(StaticBody)
				StaticBody.add_child(MeshInstance)
				StaticBody.add_child(CollisionShape)
				
				StaticBody.position = next_pos * CHUNK_SIZE
				
				var chunk = {
					"pos": next_pos,
					"body": StaticBody,
					"bitboards": bitboards
				}
				
				chunks_array.append(chunk)

func get_chunk(pos):
	var chunk_pos = floor(pos/CHUNK_SIZE)
	for chunk in chunks_array:
		if chunk.pos == chunk_pos:
			return chunk
	return
func get_chunk_data(pos):
	var bitboards:Array
	var chunk_pos = floor(pos/CHUNK_SIZE)
	var offset = pos - (chunk_pos*CHUNK_SIZE)
	for chunk in chunks_array:
		if chunk.pos == chunk_pos:
			bitboards = chunk.bitboards
			break
	if not bitboards: printerr("No chunk found for pos ", pos, " ", chunk_pos);return
	var bitboard = bitboards[offset.y]
	var bit_pos = Vector2i(offset.x, offset.z)
	if bit_pos > bitboard.get_size(): printerr("Pos ", bit_pos, " out of range! ", bitboard.get_size()); return
	return bitboard.get_bit(bit_pos.x, bit_pos.y)

func set_chunk_data(pos, bit):
	var bitboards:Array
	var chunk_pos = floor(pos/CHUNK_SIZE)
	var offset = pos - (chunk_pos*CHUNK_SIZE)
	for chunk in chunks_array:
		if chunk.pos == chunk_pos:
			bitboards = chunk.bitboards
			break
	if not bitboards: printerr("No chunk found for pos ", pos, " ", chunk_pos);return
	var bitboard = bitboards[offset.y]
	var bit_pos = Vector2i(offset.x, offset.z)
	if bit_pos > bitboard.get_size(): print("Pos ", bit_pos, " out of range! ", bitboard.get_size()); return
	bitboard.set_bit(bit_pos.x, bit_pos.y, bit)

func is_solid(pos):
	return get_chunk_data(pos)

func is_empty(pos):
	return not is_solid(pos)
