extends Node

@onready var mesh_instance_3d = $Node3D/MeshInstance3D

func _process(delta):
	mesh_instance_3d.rotate(Vector3.UP, deg_to_rad(50)*delta)
