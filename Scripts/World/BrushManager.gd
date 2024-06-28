@tool
class_name BrushManager extends Node


static var instance: BrushManager

@export var brush_textures: Array[Texture2D]

var _atlas_lookup: Dictionary = {}
var _grid_width := 4
var _grid_height: int

var Air: Brush
var brush_texture_size := Vector2i(64, 64)
var texture_atlas_size: Vector2
@export var chunk_material: ShaderMaterial

func _ready():
	instance = self
	
	Air = Brush.new()
	
	for i in range(brush_textures.size()):
		var texture = brush_textures[i]
		_atlas_lookup[texture] = Vector2i(i % _grid_width, floori(float(i) / float(_grid_width)))
	
	_grid_height = ceili(brush_textures.size() / float(_grid_width))
	
	var image = Image.create(_grid_width * brush_texture_size.x, _grid_height * brush_texture_size.y, false, Image.FORMAT_RGBA8)
	
	for x in range(_grid_width):
		for y in range(_grid_height):
			var img_index = x + y * _grid_width
			
			var current_image = brush_textures[img_index].get_image() if img_index < brush_textures.size() else brush_textures[0].get_image()
			current_image.convert(Image.FORMAT_RGBA8)
			
			image.blit_rect(current_image, Rect2i(Vector2i.ZERO, brush_texture_size), Vector2i(x, y) * brush_texture_size)
	
	var texture_atlas = ImageTexture.create_from_image(image)
	#image.save_png("res://Assets/Textures/texture_atlas.png")

	chunk_material.set_shader_parameter("texture_albedo", texture_atlas)
	
	texture_atlas_size = Vector2(_grid_width, _grid_height)
	
	chunk_material.set_shader_parameter("atlas_size", texture_atlas_size)
	
	print("Done loading %s images to make %s x %s atlas" % [brush_textures.size(), _grid_width, _grid_height])

func get_texture_atlas_position(texture: Texture2D) -> Vector2i:
	if texture == null:
		return Vector2i.ZERO
	else:
		return _atlas_lookup[texture]

func get_texture_atlas_index(texture: Texture2D) -> int:
	if texture == null:
		return 0
	else:
		return brush_textures.find(texture)
