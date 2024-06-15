extends Node

@export var grid_size := Vector3(1.0, 1.0, 1.0)
@export var world_size := Vector3(8.0, 8.0, 8.0)
const CHUNK_SIZE := Vector3(16.0, 16.0, 16.0)

var chunks_array = []

@onready var greedy_mesh = $GreedyMesh
@onready var chunks_node = $Chunks

var block_types = {
	"AIR": 0,
	"SOLID": 1
}

# Define our chunks
func _ready():
	define_chunks()
	
	var chunk_pos := []
	for child in greedy_mesh.get_children():
		if "CubeSpawner" in child.name:
			greedy_mesh.make_solid(child.global_position)
			if not floor(child.global_position/CHUNK_SIZE) in chunk_pos:
				chunk_pos.append(floor(child.global_position/CHUNK_SIZE))
			child.queue_free()
	for pos in chunk_pos:
		var chunk = get_chunk(pos)
		greedy_mesh.greedy_mesh(chunk)

func define_chunks():
	var world_size_scaled = CHUNK_SIZE * world_size
	var size = (world_size_scaled/CHUNK_SIZE)
	var start_pos = ceil(Vector3(-size.x/2, -size.y/2, -size.z/2));
	
	chunks_array.resize(to_yzx_order(size))
	
	for j in range(size.y):
		for k in range(size.z):
			for l in range(size.x):
				
				var chunk_node = Chunk.new()
				
				var next_pos = start_pos + Vector3(l, j, k)
				var index = to_yzx_order(next_pos + -start_pos)
				
				chunks_node.add_child(chunk_node)
				chunk_node.name = str("chunk", index)
				chunk_node.position = next_pos * CHUNK_SIZE
				
				chunks_array[index] = chunk_node
	pass

func to_chunk_position(pos):
	return floor(pos/CHUNK_SIZE) + ceil(world_size/2)

func get_chunk(pos):
	var chunk_pos = to_chunk_position(pos)
	return chunks_array[to_yzx_order(chunk_pos)]

func set_block(pos, type):
	var chunk = get_chunk(pos)
	if not chunk: printerr("set_block: No chunk found for pos ", pos);return
	chunk.set_block(pos, block_types[type])

func to_yzx_order(pos):
	return pos.y * 256 + pos.z * 16 + pos.x
