extends StaticBody3D
class_name VoxelBlock

var size = 1.0
var mesh: ArrayMesh
var default_texture = load("res://Assets/Textures/default_arrows.png")

var MeshInstance: MeshInstance3D
var CollisionShape: CollisionShape3D

var surfaces = {
	Vector3.MODEL_FRONT: 0,
	Vector3.MODEL_REAR: 1,
	Vector3.MODEL_RIGHT: 2,
	Vector3.MODEL_LEFT: 3,
	Vector3.MODEL_TOP: 4,
	Vector3.MODEL_BOTTOM: 5
}

func _ready():
	MeshInstance = MeshInstance3D.new()
	CollisionShape = CollisionShape3D.new()
	CollisionShape.shape = BoxShape3D.new()
	self.add_child(MeshInstance)
	self.add_child(CollisionShape)
	create_voxel(default_texture)

func create_voxel(texture):

	# Define cube data
	var vertices = {
		"fbr": Vector3(-0.5, -0.5, 0.5),
		"fbl": Vector3(0.5, -0.5, 0.5),
		"rbr": Vector3(-0.5, -0.5, -0.5),
		"rbl": Vector3(0.5, -0.5, -0.5),
		"ftr": Vector3(-0.5, 0.5, 0.5),
		"ftl": Vector3(0.5, 0.5, 0.5),
		"rtr": Vector3(-0.5, 0.5, -0.5),
		"rtl": Vector3(0.5, 0.5, -0.5)
	}

	var faces = {
		Vector3.MODEL_FRONT: ["fbr", "ftr", "ftl", "fbl"],
		Vector3.MODEL_REAR: ["rbl", "rtl", "rtr", "rbr"],
		Vector3.MODEL_RIGHT: ["rbr", "rtr", "ftr", "fbr"],
		Vector3.MODEL_LEFT: ["fbl", "ftl", "rtl", "rbl"],
		Vector3.MODEL_TOP: ["rtl", "ftl", "ftr", "rtr"],
		Vector3.MODEL_BOTTOM: ["rbr", "fbr", "fbl", "rbl"]
	}

	var uvs = [
		Vector2(0, 0.25), Vector2(0, 0), Vector2(0.25, 0) , Vector2(0.25, 0.25)
	]
	
	# Create a new ArrayMesh and SurfaceTool
	mesh = ArrayMesh.new()
	var mesh_array = []
	
	var surface_tool = SurfaceTool.new()
	var material = StandardMaterial3D.new()
	material.albedo_texture = texture
	material.texture_filter = 0
	material.cull_mode = 0
	material.vertex_color_use_as_albedo = true

	# Loop through each face
	for i in range(faces.size()):
		surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
		# Set the color for the vertices of this face
		surface_tool.set_color(Color.WHITE)
		surface_tool.set_smooth_group(i)
		# Add the vertices for this face
		for j in range(4):
			var uv: Vector2
			match faces.keys()[i]:
				Vector3.MODEL_FRONT:
					uv = uvs[j] + (0.25 * Vector2(fmod(global_position.x, 4), -fmod(global_position.y+1, 4)))
				Vector3.MODEL_REAR:
					uv = uvs[j] + (0.25 * Vector2(-fmod(global_position.x+1, 4), -fmod(global_position.y+1, 4)))
				Vector3.MODEL_RIGHT:
					uv = uvs[j] + (0.25 * Vector2(fmod(global_position.z, 4), -fmod(global_position.y+1, 4)))
				Vector3.MODEL_LEFT:
					uv = uvs[j] + (0.25 * Vector2(-fmod(global_position.z+1, 4), -fmod(global_position.y+1, 4)))
				Vector3.MODEL_TOP:
					uv = uvs[j] + (0.25 * Vector2(-fmod(global_position.x+1, 4), -fmod(global_position.z+1, 4)))
				Vector3.MODEL_BOTTOM:
					uv = uvs[j] + (0.25 * Vector2(fmod(global_position.x, 4), -fmod(global_position.z+1, 4)))

			surface_tool.set_normal(faces.keys()[i])
			surface_tool.set_uv(uv)
			surface_tool.add_vertex(size*vertices[faces.values()[i][j]])
		# Add two triangles for this face
		surface_tool.add_index(0)
		surface_tool.add_index(1)
		surface_tool.add_index(2)
		surface_tool.add_index(0)
		surface_tool.add_index(2)
		surface_tool.add_index(3)
		
		#surface_tool.add_index(i*4)
		#surface_tool.add_index(i*4 + 1)
		#surface_tool.add_index(i*4 + 2)
		#surface_tool.add_index(i*4)
		#surface_tool.add_index(i*4 + 2)
		#surface_tool.add_index(i*4 + 3)
		
		# Generate normals and tangents
		#surface_tool.generate_normals()
		surface_tool.generate_tangents()
	
		mesh_array.append(surface_tool.commit_to_arrays())
		
		surface_tool.clear()
	
	for array in mesh_array:
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, array)
	
	# Set the MeshInstance's mesh
	MeshInstance.mesh = mesh
	
	for i in range(MeshInstance.mesh.get_surface_count()):
		MeshInstance.set_surface_override_material(i, material)

func modify_voxel_face_material(normal, material):
	print(surfaces[normal])
	MeshInstance.set_surface_override_material(surfaces[normal], material)
