extends CharacterBody2D

# Constants
const SPEED: float = 300.0
const MASS:float = 200
const JUMP_FORCE: float = -500.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# Hook properties
@export var hook_scene: PackedScene = preload("res://test stuf/Hook.tscn")
var hook_instance: Area2D
var is_hook_attached: bool = false
var hook_position: Vector2
var length: float = 0.0

# Pendulum physics
var angular_velocity: float = 0.0
var angular_displacement: float = 0.0
var previous_position: Vector2
var acceleration: Vector2

func _physics_process(delta: float) -> void:
	if is_hook_attached:
		handle_swinging(delta)
		velocity.y = 0
	else:
		player_movement(delta)
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("send_hook"):
		shoot_hook()

# Player movement when not swinging
func player_movement(delta: float) -> void:
	velocity.x = SPEED if Input.is_action_pressed("ui_right") else -SPEED if Input.is_action_pressed("ui_left") else 0
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_FORCE
	move_and_slide()

# Shoot the hook
func shoot_hook() -> void:
	if not hook_instance:
		hook_instance = hook_scene.instantiate()
		hook_instance.global_position = global_position
		owner.add_child(hook_instance)
		hook_instance.set_player(self)

func handle_swinging(delta: float) -> void:
	var direction = (global_position - hook_position).normalized()
	global_position = hook_position + direction * length

	var new_position = 2.0 * global_position - previous_position + calculate_acceleration() * delta * delta
	previous_position = global_position
	global_position = new_position
	global_position = hook_position + (global_position - hook_position).normalized() * length

	move_and_slide()

func calculate_acceleration() -> Vector2:
	angular_displacement = (global_position - hook_position).angle_to(Vector2.DOWN)
	var restoring_torque = MASS * gravity * length * sin(angular_displacement)
	var angular_acceleration = -restoring_torque / (MASS * length**2)
	var tangential_acceleration = angular_acceleration * length
	return Vector2(
		tangential_acceleration * cos(angular_displacement),
		tangential_acceleration * -sin(angular_displacement)
	)

func on_grab_hook():
	var hook_to_player = global_position - hook_position
	var distance_to_hook = hook_to_player.length()
	var hook_to_player_perpendicular = Vector2(-hook_to_player.y, hook_to_player.x).normalized()
	var tangential_velocity = velocity.dot(hook_to_player_perpendicular)
	angular_velocity = tangential_velocity / distance_to_hook 
	previous_position = global_position

# Start swinging when the hook attaches
func start_swinging(hook_ref: Area2D) -> void:
	on_grab_hook()
	is_hook_attached = true
	hook_position = hook_ref.global_position
	length = floor(global_position.distance_to(hook_position)) + 20

# Detach hook and stop swinging
func detach_hook() -> void:
	is_hook_attached = false
	if hook_instance:
		hook_instance.queue_free()
		hook_instance = null
