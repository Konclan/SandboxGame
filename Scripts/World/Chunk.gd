@tool
class_name Chunk extends StaticBody3D

@export var mesh_instance: MeshInstance3D
@export var collision_shape: CollisionShape3D

const DIM = Vector3i(16, 64, 16)

const _VERTICES: Array[Vector3i] = [
	Vector3i(0, 0, 0),
	Vector3i(1, 0, 0),
	Vector3i(0, 1, 0),
	Vector3i(1, 1, 0),
	Vector3i(0, 0, 1),
	Vector3i(1, 0, 1),
	Vector3i(0, 1, 1),
	Vector3i(1, 1, 1),
]

const _TOP: Array[int] = [2, 3, 7, 6]
const _BOTTOM: Array[int] = [0, 4, 5, 1]
const _LEFT: Array[int] = [6, 4, 0, 2]
const _RIGHT: Array[int] = [3, 1, 5, 7]
const _BACK: Array[int] = [7, 5, 4, 6]
const _FRONT: Array[int] = [2, 0, 1, 3]

var _brushes := empty_array_3(DIM.x, DIM.y, DIM.z)
var _surface_tool := SurfaceTool.new()

var chunk_position: Vector3i

func set_chunk_position(pos: Vector3i):
	ChunkManager.instance.update_chunk_position(self, pos, chunk_position)
	chunk_position = pos
	call_deferred("set_global_position", Vector3i(chunk_position.x * DIM.x, chunk_position.y * DIM.y, chunk_position.z * DIM.z))
	
	generate()
	update()


func generate():
	for x in range(DIM.x):
		for y in range (DIM.y):
			for z in range(DIM.z):
				var brush: Brush
				
				var global_brush_position = chunk_position * DIM + Vector3i(x, y, z)
				
				if global_brush_position.y > 1:
					brush = BrushManager.instance.Air
				else:
					brush = Brush.new()
				
				_brushes[x][y][z] = brush


func update():
	
	var mesh = greedy_mesh()
	
	mesh_instance.mesh = mesh
	collision_shape.shape = mesh.create_trimesh_shape()


func greedy_mesh() -> Mesh:
	_surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	_surface_tool.set_material(BrushManager.instance.chunk_material)
	_surface_tool.set_custom_format(0, SurfaceTool.CUSTOM_RG_FLOAT)
	
		# Sweep over each axis (X, Y and Z)
	for d in range(3):
		var i: int; var width: int; var height: int;
		var u = (d + 1) % 3
		var v = (d + 2) % 3
		var pos = Vector3()
		var q = Vector3()
		q[d] = 1
		
		var mask = []
		mask.resize(DIM.x * DIM.z * DIM.y)
		mask.fill(0)
		
		# Check each slice of the chunk one at a time
		pos[d] = -1
		while pos[d] < DIM[d]:
			var n = 0
			for xv in range(DIM[v]): 
				pos[v] = xv
				for xu in range(DIM[u]):
					pos[u] = xu
					
					# q determines the direction (X, Y or Z) that we are searching
					var blockCurrent = 1 if pos[d] >= 0 and is_solid(pos) else 0
					var blockCompare = 1 if pos[d] < DIM[d] - 1 and is_solid(pos + q) else 0
					
					if bool(blockCurrent) == bool(blockCompare):
						mask[n] = 0
					elif bool(blockCurrent):
						mask[n] = _brushes[pos.x][pos.y][pos.z].get_texture_index_from_normal(q) + 1
					else:
						mask[n] = -(_brushes[pos.x + q.x][pos.y + q.y][pos.z + q.z].get_texture_index_from_normal(-q) + 1)
						
					n += 1
			
			pos[d] += 1
			
			n = 0
			
			# Generate a mesh from the mask using lexicographic ordering,      
			#   by looping over each block in this slice of the chunk
			for j in range(DIM[v]):
				i = 0
				while i < DIM[u]:
					
					var c = mask[n]
					if bool(c):
						
						# Compute the width of this quad and store it in w                        
						#   This is done by searching along the current axis until mask[n + w] is false
						width = 1
						while c == mask[n + width] and i + width < DIM[u]:
							width += 1
							
						# Compute the height of this quad and store it in h                        
						#   This is done by checking if every block next to this row (range 0 to w) is also part of the mask.
						#   For example, if w is 5 we currently have a quad of dimensions 1 x 5. To reduce triangle count,
						#   greedy meshing will attempt to expand this quad out to DIM x 5, but will stop if it reaches a hole in the mask
						var done = false
						height = 1
						while j + height < DIM[v]:
							# Check each block next to this quad
							for k in range(width):
								# If there's a hole in the mask, exit
								if c != mask[n + k + height * DIM[u]]:
									done = true
									break
							if done: break
							height += 1
						
						pos[u] = i
						pos[v] = j
						
						# du and dv determine the size and orientation of this face
						var du = Vector3()
						var dv = Vector3()
						
						if c > 0:
							du[v] = height
							dv[u] = width
						else:
							c = -c
							
							dv[v] = height
							du[u] = width
						
						# Create a quad for this face. Colour, normal or textures are not stored in this block vertex format.
						
						new_quad(
							Vector3(pos.x, pos.y, pos.z), # Top left vertice
							Vector3(pos.x + du.x, pos.y + du.y, pos.z + du.z), # Top right vertice
							Vector3(pos.x + du.x + dv.x, pos.y + du.y + dv.y, pos.z + du.z + dv.z), # Bottom right vertice
							Vector3(pos.x + dv.x, pos.y + dv.y, pos.z + dv.z), # Bottom left vertice
							c,
							)
						
						# Clear this part of the mask, so we don't add duplicate faces
						for l in range(height):
							for k in range(width):
								mask[n + k + l * DIM[u]] = 0
						
						# Increment counters and continue
						i += width
						n += width
					else:
						i += 1
						n += 1
	
	return _surface_tool.commit()

func new_quad(point_1: Vector3, point_2: Vector3, point_3: Vector3, point_4: Vector3, texture_index: int):
	var brush_texture = BrushManager.instance.brush_textures[texture_index - 1]
	
	var texture_position = BrushManager.instance.get_texture_atlas_position(brush_texture) as Vector2
	var texture_atlas_size = BrushManager.instance.texture_atlas_size
	
	var normal = Vector3(point_3-point_1).cross(Vector3(point_2-point_1)).normalized()
	var width = (point_4 - point_1).length()
	var height = (point_2 - point_1).length()
	
	var triangle1: Array[Vector3] = [point_1, point_2, point_3]
	var triangle2: Array[Vector3] = [point_1, point_3, point_4]
	
	var uvOffset = texture_position / texture_atlas_size
	var uvWidth = (1.0 / texture_atlas_size.x) * width
	var uvHeight = (1.0 / texture_atlas_size.y) * height
	
	var uvA = uvOffset + Vector2(0, 0)
	var uvB = uvOffset + Vector2(0, uvHeight)
	var uvC = uvOffset + Vector2(uvWidth, uvHeight)
	var uvD = uvOffset + Vector2(uvWidth, 0)
	
	var uv_triangle1: Array[Vector2] = [uvA, uvB, uvC]
	var uv_triangle2: Array[Vector2] = [uvA, uvC, uvD]
	
	_surface_tool.set_normal(normal)
	_surface_tool.set_custom(0, Color(int(texture_position.x), int(texture_position.y), 0.0, 0.0))
	_surface_tool.add_triangle_fan(triangle1, uv_triangle1)
	_surface_tool.add_triangle_fan(triangle2, uv_triangle2)
	
func is_solid(pos: Vector3i) -> bool:
	return _brushes[pos.x][pos.y][pos.z] != BrushManager.instance.Air


func set_brush(brush_position: Vector3i, brush: Brush):
	_brushes[brush_position.x][brush_position.y][brush_position.z] = brush
	update()
	
func set_brush_face_texture(brush_position: Vector3i, normal: Vector3i, texture_index: int):
	var brush: Brush = _brushes[brush_position.x][brush_position.y][brush_position.z]
	brush.set_texture_from_normal(normal, BrushManager.instance.brush_textures[texture_index])
	
	update()


func empty_array_3(size_x: int, size_y: int, size_z: int, contents = null) -> Array:
	var inner: = []
	inner.resize(size_z)
	if contents != null:
		inner.fill(contents)
	
	var mid: = []
	mid.resize(size_y)
	for y in size_y:
		mid[y] = inner.duplicate(true)
	
	var outer: = []
	outer.resize(size_x)
	for x in size_x:
		outer[x] = mid.duplicate(true)
	return outer
