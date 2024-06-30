@tool
class_name BrushManager extends Node


static var instance: BrushManager

var Air: Brush

func _ready():
	instance = self
	
	Air = Brush.new()
