@tool
class_name MaterialManager extends Node


static var instance: MaterialManager

@export var brush_materials: Array[BMaterial]

var _material_lookup: Dictionary = {}
var _array_lookup: Dictionary = {}

@export var chunk_material: ShaderMaterial

func _ready():
	instance = self

	var images: Array[Image]
	for i in range(brush_materials.size()):
		var texture = brush_materials[i].texture
		_material_lookup[brush_materials[i].id] = brush_materials[i]
		_array_lookup[brush_materials[i]] = i
	
		var current_image = texture.get_image()
		current_image.convert(Image.FORMAT_RGBA8)
		
		images.append(current_image)
	
	var texture_array:Texture2DArray = Texture2DArray.new()
	texture_array.create_from_images(images)
	
	chunk_material.set_shader_parameter("texture_array_albedo", texture_array)
	
	print("Done loading %s images to make texture array" % [brush_materials.size()])

func get_material(material_name: String) -> BMaterial:
	return _material_lookup.get(material_name)

func get_material_index(material: BMaterial) -> int:
	return _array_lookup[material]
