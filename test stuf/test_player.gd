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

func _physics_process(delta: float) -> void:
	velocity.y = 300
	if is_hook_attached:
		handle_swinging(delta)
	else:
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
	velocity.x = calculate_tangential_velocity() * abs(cos(angular_displacement)) * delta
	move_and_slide()

# obliczanie prędkości obwodowej...pisanie tego zajeło pół dnia :(
func calculate_tangential_velocity() -> float:
	angular_displacement = (global_position - hook_position).angle_to(Vector2.DOWN)
	var restoring_torque = MASS * 9.6 * length * sin(angular_displacement)
	angular_velocity += -restoring_torque / length**2
	return  angular_velocity * length

# Start swinging when the hook attaches
func start_swinging(hook_ref: Area2D) -> void:
	velocity.x += sign(velocity.x) * (velocity.y / length)#nie wiem jak to opisać ale to tak jakby konwertuje prędkość z jaką spadasz na horyzontalną predkość 
	is_hook_attached = true
	hook_position = hook_ref.global_position
	length = global_position.distance_to(hook_position)

# Detach hook and stop swinging
func detach_hook() -> void:
	is_hook_attached = false
	if hook_instance:
		hook_instance.queue_free()
		hook_instance = null
