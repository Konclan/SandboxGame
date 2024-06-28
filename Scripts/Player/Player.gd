class_name Player extends CharacterBody3D

@export var user_interaction: UserInteraction
@export var camera_controller: Node3D
@export var user_interface: UserInterface
@export var Camera: Camera3D
@export var RayCast: RayCast3D

@export var _mouse_sensitivity := 0.3
@export var _movement_speed := 16.0

# Private variables (start with _)
var _camera_rotation_x: float
var _camera_locked: bool

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent):
	if not _camera_locked:
		if event is InputEventMouseMotion:
			var mouseMotion = event as InputEventMouseMotion
			var deltaX = mouseMotion.relative.y * _mouse_sensitivity
			var deltaY = -mouseMotion.relative.x * _mouse_sensitivity
			
			camera_controller.rotate_y(deg_to_rad(deltaY))
			if _camera_rotation_x + deltaX > -90 && _camera_rotation_x + deltaX < 90:
				Camera.rotate_x(deg_to_rad(-deltaX))
				_camera_rotation_x += deltaX

func _process(_delta):
	if Input.is_action_just_pressed("toggle_focus"):
		if _camera_locked:
			unlock_camera()
		else:
			lock_camera()

func _physics_process(_delta):
	if not _camera_locked:
		var Velocity = velocity
		
		# Get the input direction and handle the movement/deceleration.
		var input_direction_xz = Input.get_vector("move_left", "move_right", "move_back", "move_forward").normalized()
		var input_direction_y = Input.get_axis("move_down", "move_up")
		
		var direction = Vector3.ZERO

		direction += input_direction_xz.x * camera_controller.global_basis.x

		# Forward is the negative Z direction
		direction += input_direction_xz.y * -camera_controller.global_basis.z
		
		direction += input_direction_y * camera_controller.global_basis.y

		Velocity.x = direction.x * _movement_speed
		Velocity.y = direction.y * _movement_speed
		Velocity.z = direction.z * _movement_speed

		velocity = Velocity
	move_and_slide()

func lock_camera():
	_camera_locked = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func unlock_camera():
	_camera_locked = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_line_edit_focus_entered():
	lock_camera()


func _on_line_edit_focus_exited():
	unlock_camera()
