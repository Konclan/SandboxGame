extends StaticBody3D
class_name VoxelBlock

@onready var mesh_instance = $MeshInstance3D
var size = 1
var mesh: ArrayMesh

func _ready():
	create_voxel()

func create_voxel():
	# Define cube data
	var vertices = [
		Vector3(-0.5, -0.5, -0.5), Vector3(-0.5, -0.5, 0.5), Vector3(-0.5, 0.5, 0.5), Vector3(-0.5, 0.5, -0.5),
		Vector3(0.5, -0.5, -0.5), Vector3(0.5, -0.5, 0.5), Vector3(0.5, 0.5, 0.5), Vector3(0.5, 0.5, -0.5)
	]
	var faces = [
		[3, 2, 1, 0], [4, 5, 6, 7], [0, 1, 5, 4], [1, 2, 6, 5], [2, 3, 7, 6], [4, 7, 3, 0]
	]		
	var colors = [
		Color.RED, Color.GREEN, Color.BLUE, Color.YELLOW, Color.MAGENTA, Color.CYAN
	]

	# Create a new ArrayMesh and SurfaceTool
	mesh = ArrayMesh.new()
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	# Loop through each face
	for i in range(faces.size()):
		# Set the color for the vertices of this face
		surface_tool.set_color(colors[i])
		surface_tool.set_smooth_group(i)
		# Add the vertices for this face
		for j in range(4):
			surface_tool.add_vertex(size*vertices[faces[i][j]])
		# Add two triangles for this face
		surface_tool.add_index(i*4)
		surface_tool.add_index(i*4 + 1)
		surface_tool.add_index(i*4 + 2)
		surface_tool.add_index(i*4)
		surface_tool.add_index(i*4 + 2)
		surface_tool.add_index(i*4 + 3)

	# Generate normals and tangents
	surface_tool.generate_normals()
	#surface_tool.generate_tangents()

	# Commit to the mesh
	surface_tool.commit(mesh)

	# Set the MeshInstance's mesh
	mesh_instance.mesh = mesh
	
	var material = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	mesh_instance.set_surface_override_material(0, material)

func modify_voxel(color):
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	for i in range(mdt.get_vertex_count()):
		var vertex = mdt.get_vertex(i)
		mdt.set_vertex_color(i, color)
		mdt.set_vertex(i, vertex)
	mesh.clear_surfaces()
	mdt.commit_to_surface(mesh)
	mesh_instance.mesh = mesh
	#var mesh = ArrayMesh.new()
	#mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, BoxMesh.new().get_mesh_arrays())
	#var mdt = MeshDataTool.new()
	#mdt.create_from_surface(mesh, 0)
	#for i in range(mdt.get_vertex_count()):
		#var vertex = mdt.get_vertex(i)
		## In this example we extend the mesh by one unit, which results in separated faces as it is flat shaded.
		#vertex += mdt.get_vertex_normal(i)
		## Save your change.
		#mdt.set_vertex(i, vertex)
	#mesh.clear_surfaces()
	#mdt.commit_to_surface(mesh)
	#var mi = MeshInstance.new()
	#mi.mesh = mesh
	#add_child(mi)
