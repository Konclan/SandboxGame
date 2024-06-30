class_name Brush extends Resource
# A generic voxel box where each face texture can be changed

class face extends Resource:
	var normal: Vector3
	var material: BMaterial
	
	func _init(normal: Vector3, material: BMaterial):
		self.normal = normal
		self.material = material

var face_front: face = face.new(Vector3.FORWARD, MaterialManager.instance.get_material("mat_nodraw"))
var face_back: face = face.new(Vector3.BACK, MaterialManager.instance.get_material("mat_nodraw"))
var face_left: face = face.new(Vector3.LEFT, MaterialManager.instance.get_material("mat_nodraw"))
var face_right: face = face.new(Vector3.RIGHT, MaterialManager.instance.get_material("mat_nodraw"))
var face_top: face = face.new(Vector3.UP, MaterialManager.instance.get_material("mat_nodraw"))
var face_bottom: face = face.new(Vector3.DOWN, MaterialManager.instance.get_material("mat_nodraw"))

var _faces: Array[face] = [
	face_front,
	face_back,
	face_left,
	face_right,
	face_top,
	face_bottom,
]

var _face_lookup: Dictionary = {}

func _init():
	for face in _faces:
		_face_lookup[face.normal] = face

func get_face_from_normal(normal: Vector3) -> Resource:
	var face = _face_lookup.get(normal)
	if not face:
		printerr("No face for normal: ", normal, _face_lookup)
	return face
