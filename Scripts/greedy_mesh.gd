extends Node3D

@onready var World = $".."
@onready var grid_size = World.grid_size

const GREEDY_CUBE = preload("res://Assets/Materials/greedy_cube.gdshader")

func make_solid(pos):
	World.set_block(pos.snapped(grid_size), "SOLID")

func make_new_solid(pos):
	make_solid(pos)
	update_chunk_mesh(World.get_chunk(pos))

func remove_solid(pos):
	World.set_block(pos.snapped(grid_size), "AIR")
	update_chunk_mesh(World.get_chunk(pos))

func new_quad(point_1: Vector3, point_2: Vector3, point_3: Vector3, point_4: Vector3):
	var array_quad_vertices := []
	var array_quad_indices := []

	var vertex_index_one = -1
	var vertex_index_two = -1
	var vertex_index_three = -1
	var vertex_index_four = -1
	
	vertex_index_one = _add_or_get_vertex_from_array(point_1, array_quad_vertices)
	vertex_index_two = _add_or_get_vertex_from_array(point_2, array_quad_vertices)
	vertex_index_three = _add_or_get_vertex_from_array(point_3, array_quad_vertices)
	vertex_index_four = _add_or_get_vertex_from_array(point_4, array_quad_vertices)
	
	array_quad_indices.append(vertex_index_one)
	array_quad_indices.append(vertex_index_two)
	array_quad_indices.append(vertex_index_three)
	
	array_quad_indices.append(vertex_index_one)
	array_quad_indices.append(vertex_index_three)
	array_quad_indices.append(vertex_index_four)
	
	return {"vertices": array_quad_vertices, "indices": array_quad_indices}

func _add_or_get_vertex_from_array(vert: Vector3, vertices: Array):
	var vert_check = vertices.find(vert)
	if vert_check > -1:
		return vert_check
	
	else:
		vertices.append(vert)
		
		return vertices.size()-1

func update_chunk_mesh(chunk):
	if not chunk: printerr("greedy_mesh(): No chunk"); return

	# Todo: Fix the lag with threading probably
	greedy_mesh(chunk)



func greedy_mesh(chunk):
	var chunk_size = World.CHUNK_SIZE
	var array_quads := []
	
	# Sweep over each axis (X, Y and Z)
	for d in range(3):
		var i: int; var width: int; var height: int;
		var u = (d + 1) % 3
		var v = (d + 2) % 3
		var pos = Vector3()
		var q = Vector3()
		q[d] = 1
		
		var mask = []
		var flip = []
		for a in range(chunk_size.x * chunk_size.z * chunk_size.y):
			mask.append(false)
			flip.append(false)
		
		# Check each slice of the chunk one at a time
		pos[d] = -1
		while pos[d] < chunk_size[d]:
			var n = 0
			for xv in range(chunk_size[v]): 
				pos[v] = xv
				for xu in range(chunk_size[u]):
					pos[u] = xu
					
					# q determines the direction (X, Y or Z) that we are searching
					# m.IsBlockAt(x,y,z) takes global map positions and returns true if a block exists there
					
					var blockCurrent = true if pos[d] >= 0 and chunk.is_solid(pos) else false
					var blockCompare = true if pos[d] < chunk_size[d] - 1 and chunk.is_solid(pos + q) else false
					
					# The mask is set to true if there is a visible face between two blocks,
					#   i.e. both aren't empty and both aren't blocks
					mask[n] = blockCurrent != blockCompare
					flip[n] = blockCompare
					n += 1
			
			pos[d] += 1
			
			n = 0
			
			# Generate a mesh from the mask using lexicographic ordering,      
			#   by looping over each block in this slice of the chunk
			for j in range(chunk_size[v]):
				i = 0
				while i < chunk_size[u]:
					if mask[n]:
						
						# Compute the width of this quad and store it in w                        
						#   This is done by searching along the current axis until mask[n + w] is false
						width = 1
						while i + width < chunk_size[u] and mask[n + width] and flip[n] == flip[n + width]:
							width += 1
							
						# Compute the height of this quad and store it in h                        
						#   This is done by checking if every block next to this row (range 0 to w) is also part of the mask.
						#   For example, if w is 5 we currently have a quad of dimensions 1 x 5. To reduce triangle count,
						#   greedy meshing will attempt to expand this quad out to CHUNK_SIZE x 5, but will stop if it reaches a hole in the mask
						var done = false
						height = 1
						while j + height < chunk_size[v]:
							# Check each block next to this quad
							for k in range(width):
								# If there's a hole in the mask, exit
								if !mask[n + k + height * chunk_size[u]] or flip[n] != flip[n + k + height * chunk_size[u]]:
									done = true
									break
							if done: break
							height += 1
						
						pos[u] = i
						pos[v] = j
						
						# du and dv determine the size and orientation of this face
						var du = Vector3()
						du[u] = width
						
						var dv = Vector3()
						dv[v] = height
						
						# Create a quad for this face. Colour, normal or textures are not stored in this block vertex format.
						if flip[n]:
							array_quads.append(new_quad(
								Vector3(pos.x, pos.y, pos.z), # Top left vertice
								Vector3(pos.x + du.x, pos.y + du.y, pos.z + du.z), # Top right vertice
								Vector3(pos.x + du.x + dv.x, pos.y + du.y + dv.y, pos.z + du.z + dv.z), # Bottom right vertice
								Vector3(pos.x + dv.x, pos.y + dv.y, pos.z + dv.z), # Bottom left vertice
								))
						else:
							array_quads.append(new_quad(
								Vector3(pos.x, pos.y, pos.z), # Top left vertice
								Vector3(pos.x + dv.x, pos.y + dv.y, pos.z + dv.z), # Bottom left vertice
								Vector3(pos.x + du.x + dv.x, pos.y + du.y + dv.y, pos.z + du.z + dv.z), # Bottom right vertice
								Vector3(pos.x + du.x, pos.y + du.y, pos.z + du.z), # Top right vertice
								))
						
						# Clear this part of the mask, so we don't add duplicate faces
						for l in range(height):
							for k in range(width):
								mask[n + k + l * chunk_size[u]] = false
						
						# Increment counters and continue
						i += width
						n += width
					else:
						i += 1
						n += 1

	var MeshInstance = chunk.MeshInstance
	var CollisionShape = chunk.CollisionShape
	
	if array_quads:
		# Generate faces
		var mesh = ArrayMesh.new()
		var surface_tool = SurfaceTool.new()

		surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
		for i in range(array_quads.size()):
			surface_tool.set_smooth_group(i)
			var quad = array_quads[i]
			for vert in quad.vertices:
				surface_tool.add_vertex(vert)
			for ind in quad.indices:
				surface_tool.add_index((i*4) + ind)
			
		surface_tool.generate_normals()
		surface_tool.commit(mesh)
		
		MeshInstance.mesh = mesh
		CollisionShape.shape = mesh.create_trimesh_shape()
		var mat = ShaderMaterial.new()
		mat.shader = GREEDY_CUBE
		MeshInstance.set_surface_override_material(0, mat)
	else:
		MeshInstance.mesh = null
		CollisionShape.shape = null
