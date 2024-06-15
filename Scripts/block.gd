extends Node3D
class_name Block

var default_texture = load("res://Assets/Textures/default_arrows.png")
var default_material = StandardMaterial3D.new()


var faces = {
	"front": null,
	"rear": null,
	"left": null,
	"right": null,
	"top": null,
	"bottom": null,
}

var uv_offset = Vector2(0, 0)

func _init():
	for face in faces:
		face = {
		"material": default_material,
		"axis": 0
		}
		
	default_material.albedo_texture = default_texture
	default_material.texture_filter = 0
	default_material.cull_mode = 0
	default_material.vertex_color_use_as_albedo = true
