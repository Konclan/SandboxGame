extends StaticBody3D

@onready var mesh_instance = $MeshInstance3D

func _ready():
	create_colored_cube()

func create_colored_cube():
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
	var mesh = ArrayMesh.new()
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	# Loop through each face
	for i in range(faces.size()):
		# Set the color for the vertices of this face
		surface_tool.set_color(colors[i])
		surface_tool.set_smooth_group(i)
		# Add the vertices for this face
		for j in range(4):
			surface_tool.add_vertex(vertices[faces[i][j]])
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
