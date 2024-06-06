extends CharacterBody3D

# Constants
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const GRID = Vector3(1, 1, 1)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_sensitivity := 0.001
var mouse_input_x := 0.0
var mouse_input_y := 0.0
var camera_zoom := 5.0
var direction := Vector3(0, 0, 0)

var camera_locked := false
var lock_movement := false

@onready var player_collision := $CollisionShape3D
@onready var camera_controller := $CameraController
@onready var twist_pivot := $CameraController/TwistPivot
@onready var pitch_pivot := $CameraController/TwistPivot/PitchPivot
@onready var spring_arm := $CameraController/TwistPivot/PitchPivot/SpringArm3D
@onready var debug_text := $UI/debug_text

@onready var camera := $CameraController/TwistPivot/PitchPivot/SpringArm3D/Camera3D
@onready var arrow := $Arrow

const Block = preload("res://Voxels/Blocks/block.tscn")

func _ready():
	spring_arm.add_excluded_object(self)

func _process(delta):
	
	if camera_locked == false:
		if Input.is_action_just_pressed("camera_focus"):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		elif Input.is_action_just_released("camera_focus"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE	

		if Input.is_action_just_released("camera_zoom_in"):
			camera_zoom += -1
		elif Input.is_action_just_released("camera_zoom_out"):
			camera_zoom += 1
		
		camera_zoom = clamp(camera_zoom, 1, 9)
		spring_arm.spring_length = camera_zoom
		
		if not Input.is_action_pressed("shift"):
			twist_pivot.rotate_y(mouse_input_x * mouse_sensitivity)
			pitch_pivot.rotate_x(mouse_input_y * mouse_sensitivity)
			pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, deg_to_rad(-85), deg_to_rad(85))
		
			mouse_input_x = 0.0
			mouse_input_y = 0.0
	
	var scene = get_tree().current_scene
	
	var cursor_raycast = get_cursor_pos()
	
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		if Input.is_action_just_pressed("primary_action"):
			if cursor_raycast:
				var pos = (cursor_raycast.position + (cursor_raycast.normal * 0.1)).snapped(GRID)
				print(cursor_raycast.position, pos)
				var check_pos = check_point(pos, [self])
				print(check_pos)
				if not check_pos:
					print("Placing block!")
					var block_new = Block.instantiate()
					block_new.position = pos
					scene.find_child("Blocks").add_child(block_new)
					block_new.name = "Block"
		if Input.is_action_just_pressed("secondary_action"):
			if cursor_raycast:
				var object = cursor_raycast.collider
				print(object.name)
				if object.name.contains("Block"):
					object.queue_free()

	if cursor_raycast:
		arrow.visible = true
		var target_position = cursor_raycast.position
		var target_normal = cursor_raycast.normal
		var new_position = target_position + (1 * target_normal)
	
		arrow.position = new_position
		
		if not arrow.position.is_equal_approx(target_position):
			if target_normal.is_equal_approx(Vector3.UP):
				arrow.rotation = Vector3(deg_to_rad(-90), 0, 0)
			elif target_normal.is_equal_approx(Vector3.DOWN):
				arrow.rotation = Vector3(deg_to_rad(90), 0, 0)
			else:
				arrow.look_at(target_position)
			
		
		debug_text.text = str("Arrow Position: ", arrow.position, "\nArrow Rotation:", arrow.rotation, "\nCursor Position: ", target_position, "\nCursor Normal: ", target_normal, "\nDiff: ", (new_position - target_position))
	else:
		arrow.visible = false

func get_cursor_pos():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 100
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	ray_query.collide_with_areas = false
	ray_query.exclude = [self]
	var result = space.intersect_ray(ray_query)
	return result

func check_point(pos, exclude):
	var point_query = PhysicsPointQueryParameters3D.new()
	var space = get_world_3d().direct_space_state
	point_query.position = pos
	point_query.collide_with_areas = false
	point_query.collide_with_bodies = true
	point_query.exclude = exclude
	var result = space.intersect_point(point_query)
	return result
	

func _physics_process(delta):
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var input_dir_y = Input.get_axis("move_down", "move_up")
	var speed = SPEED
	
	if camera_locked == false:
		if Input.is_action_pressed("camera_focus") and Input.is_action_pressed("shift"):
			direction = (twist_pivot.basis * pitch_pivot.basis * Vector3(-mouse_input_x, mouse_input_y, 0)).normalized()
			mouse_input_x = 0.0
			mouse_input_y = 0.0
			speed = 10 * camera_zoom/9
		else:
			direction = (twist_pivot.basis * pitch_pivot.basis * Vector3(input_dir.x, 0, input_dir.y) + Vector3(0, input_dir_y, 0)).normalized()
		
		if Input.is_action_pressed("shift") and not Input.is_action_pressed("camera_focus"):
			speed = SPEED*2
	
	if direction:
		velocity.x = direction.x * speed
		velocity.y = direction.y * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	
	# Make Camera Controller match position of player
	camera_controller.position = lerp(camera_controller.position, position, delta * 25)

func _input(event):
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			mouse_input_x = - event.relative.x
			mouse_input_y = - event.relative.y

func lock_camera():
	camera_locked = true

func unlock_camera():
	camera_locked = false

func _on_line_edit_focus_entered():
	lock_camera()


func _on_line_edit_focus_exited():
	unlock_camera()
