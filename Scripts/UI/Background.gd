extends Node

@export var mesh_instance: MeshInstance3D

func _process(delta):
	mesh_instance.rotate(Vector3.UP, deg_to_rad(50)*delta)
