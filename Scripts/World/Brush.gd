class_name Brush extends Resource
# A generic voxel box where each face texture can be changed

var front_texture: Texture2D = BrushManager.instance.brush_textures[2]
var back_texture: Texture2D = BrushManager.instance.brush_textures[2]
var left_texture: Texture2D = BrushManager.instance.brush_textures[2]
var right_texture: Texture2D = BrushManager.instance.brush_textures[2]
var top_texture: Texture2D = BrushManager.instance.brush_textures[3]
var bottom_texture: Texture2D = BrushManager.instance.brush_textures[4]

var textures: Array[Texture2D] = [
	front_texture,
	back_texture,
	left_texture,
	right_texture,
	top_texture,
	bottom_texture,
]

var faces = {
	Vector3i.FORWARD: 0,
	Vector3i.BACK: 1,
	Vector3i.LEFT: 2,
	Vector3i.RIGHT: 3,
	Vector3i.UP: 4,
	Vector3i.DOWN: 5,
}

func get_texture_from_normal(normal: Vector3i) -> Texture2D:
	return textures[faces[normal]]

func set_texture_from_normal(normal: Vector3i, texture: Texture2D) -> void:
	textures[faces[normal]] = texture
	
func set_texture_from_index(index: int, texture: Texture2D) -> void:
	textures[index] = texture

func get_texture_index_from_normal(normal: Vector3i) -> int:
	var texture = textures[faces[normal]]
	if texture:
		return BrushManager.instance.get_texture_atlas_index(texture)
	else:
		return 0
