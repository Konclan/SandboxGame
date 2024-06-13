extends CharacterBody3D
class_name Player

# Constants
const SPEED = 5.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_sensitivity := 0.01
var mouse_input_x := 0.0
var mouse_input_y := 0.0
var camera_zoom := 5.0
var direction := Vector3(0, 0, 0)
var camera_locked := false

#@onready var player_collision := $CollisionShape3D
@onready var player_interaction = $PlayerInteraction
@onready var camera_controller := $CameraController
@onready var twist_pivot := $CameraController/TwistPivot
@onready var pitch_pivot := $CameraController/TwistPivot/PitchPivot
@onready var spring_arm := $CameraController/TwistPivot/PitchPivot/SpringArm3D
@onready var camera := $CameraController/TwistPivot/PitchPivot/SpringArm3D/Camera3D

func _ready():
	spring_arm.add_excluded_object(self)

func _physics_process(delta):
	player_movement(delta)
	camera_movement(delta)

func _input(event):
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			mouse_input_x = - event.relative.x
			mouse_input_y = - event.relative.y

func player_movement(_delta):
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var input_dir_y = Input.get_axis("move_down", "move_up")
	var speed = SPEED
	
	if camera_locked == false:
		if Input.is_action_pressed("camera_focus") and Input.is_action_pressed("shift"):
			direction = (twist_pivot.basis * pitch_pivot.basis * Vector3(-mouse_input_x, mouse_input_y, 0)).normalized()
			mouse_input_x = 0.0
			mouse_input_y = 0.0
			speed = 30 * camera_zoom/9
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

func camera_movement(delta):
	# Make Camera Controller match position of player
	camera_controller.position = lerp(camera_controller.position, position, delta * 5)
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

func lock_camera():
	camera_locked = true

func unlock_camera():
	camera_locked = false

func _on_line_edit_focus_entered():
	lock_camera()


func _on_line_edit_focus_exited():
	unlock_camera()
