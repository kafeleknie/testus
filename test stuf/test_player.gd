extends CharacterBody2D

# Constants
const SPEED: float = 100
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

func _physics_process(delta: float) -> void:
	if is_hook_attached:
		velocity.y = 0
		handle_swinging(delta)
	else:
		velocity.y += gravity * delta
	player_movement(delta)

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
	var distance_to_hook = global_position.distance_to(hook_position)
	update_angular_velocity(delta)
	var angular_displacement = (global_position - hook_position).angle_to(Vector2.UP)
	velocity.x = angular_velocity * -cos(angular_displacement) * delta
	velocity.y = angular_velocity * sin(angular_displacement) * delta
	move_and_slide()

func update_angular_velocity(delta) -> void:
	var angular_displacement = (global_position - hook_position).angle_to(Vector2.UP)
	var restoring_torque = MASS * gravity * length * sin(-angular_displacement)
	angular_velocity += (-restoring_torque / (length**2))

func restrict_player_distance(delta: float,distance_to_hook:float) -> void:
	if distance_to_hook > length :
		velocity.y = 0
		var direction = (global_position - hook_position).normalized()
		var excess_distance = distance_to_hook - length
		global_position -= direction * excess_distance
	

func start_swinging(hook_ref: Area2D) -> void:
	is_hook_attached = true
	hook_position = hook_ref.global_position
	length = global_position.distance_to(hook_position) + 20

# Detach hook and stop swinging
func detach_hook() -> void:
	is_hook_attached = false
	if hook_instance:
		hook_instance.queue_free()
		hook_instance = null
