extends CharacterBody3D
class_name Player

@export_group("Movement")
@export var speed: float = 10
@export var speed_sprint: float = 15
@export var jump_vel: float = 25
@export var gravity: float = 100

@export_group("Look")
@export var cam_root: Node3D
@export var cam: Camera3D
@export var mouse_sens: float = 0.12


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	_update_physics_tps()


func _update_physics_tps() -> void:
	var monitor_refresh_rate: float = DisplayServer.screen_get_refresh_rate()
	if monitor_refresh_rate <= 0:
		monitor_refresh_rate = 60
	
	var target_clicks: int = int(monitor_refresh_rate)
	Engine.physics_ticks_per_second = target_clicks


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * mouse_sens
		cam.rotation_degrees.x -= event.relative.y * mouse_sens
		cam.rotation_degrees.x = clampf(cam.rotation_degrees.x, -90, 90)


func _physics_process(delta: float) -> void:
	# Gravity and Jump
	if is_on_floor():
		velocity.y = 0
		
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_vel
	else:
		velocity.y -= gravity * delta
	
	# Movement
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	var move_dir: Vector3 = global_basis * Vector3(input_dir.x, 0, input_dir.y)
	move_dir = move_dir.normalized()
	
	if move_dir:
		velocity.x = move_dir.x * _get_speed()
		velocity.z = move_dir.z * _get_speed()
	else:
		velocity.x = 0
		velocity.z = 0
	
	# Execute
	move_and_slide()


func _get_speed() -> float:
	if Input.is_action_pressed("sprint"):
		return speed_sprint
	else:
		return speed
