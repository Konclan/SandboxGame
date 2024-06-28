@tool
class_name ChunkManager extends Node


static var instance: ChunkManager

var _chunk_to_position := {}
var _position_to_chunk := {}
var _chunks: Array[Chunk]
var _width := 8
var _height := 1

@export var chunk_scene: PackedScene
var is_done_generating := false


func _ready():
	instance = self
	
	for i in range(_height * _width**2):
		var chunk: Chunk = chunk_scene.instantiate() as Chunk
		get_parent().call_deferred("add_child", chunk)
		_chunks.append(chunk)
	
	for x in range(_width):
		for y in range(_height):
			for z in range(_width):
				var index = y * _width**2 + z * _width + x
				var half_width = floori(_width / 2.0)
				var half_height = floori(_height / 2.0)
				_chunks[index].set_chunk_position(Vector3i(x - half_width, y - half_height, z - half_width))
	
	is_done_generating = true


func update_chunk_position(chunk: Chunk , current_position: Vector3i, previous_position: Vector3i):
	if _position_to_chunk.has(previous_position):
		var chunk_at_position = _position_to_chunk.get(previous_position)
		if chunk_at_position == chunk:
			_position_to_chunk.erase(previous_position)

	_chunk_to_position[chunk] = current_position
	_position_to_chunk[current_position] = chunk


func set_brush(global_position: Vector3i, brush: Brush):
	var chunk_tile_position = Vector3i(floori(global_position.x / float(Chunk.DIM.x)), floori(global_position.y / float(Chunk.DIM.y)), floori(global_position.z / float(Chunk.DIM.z)))

	if _position_to_chunk.has(chunk_tile_position):
		var chunk = _position_to_chunk.get(chunk_tile_position)
		chunk.set_brush(Vector3i(Vector3(global_position) - chunk.global_position), brush)


func set_brush_texture_face(global_position: Vector3i, normal: Vector3i, texture_index: int):
	var chunk_tile_position = Vector3i(floori(global_position.x / float(Chunk.DIM.x)), floori(global_position.y / float(Chunk.DIM.y)), floori(global_position.z / float(Chunk.DIM.z)))

	if _position_to_chunk.has(chunk_tile_position):
		var chunk = _position_to_chunk.get(chunk_tile_position)
		chunk.set_brush_face_texture(Vector3i(Vector3(global_position) - chunk.global_position), Vector3i(normal), texture_index)
