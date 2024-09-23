extends CharacterBody2D

# Constants
const SPEED: float = 180.0
const MASS:float = 10
const JUMP_FORCE: float = -500.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# Hook properties
var hook_scene: PackedScene = preload("res://test stuf/Hook.tscn")
var hook_instance: Area2D
var is_hook_attached: bool = false
var hook_position: Vector2 = Vector2.ZERO
var length: float = 0.0

#swinging properties
var is_swinging: bool = false
var angle: float = 0.0
var acceleration: float = 0.0 
var swing_velocity: float = 0.0
var damping_factor: float = 1 
var prevoius_position: Vector2 = Vector2.ZERO


func _physics_process(delta: float) -> void:
	if is_swinging:
		handle_swinging(delta)
	elif is_hook_attached:
		start_swinging()
	else:
		player_movement(delta)
		velocity.y += gravity * delta
	move_and_slide()
	if Input.is_action_just_pressed("send_hook"):
		shoot_hook()
		if(is_swinging):
			stop_swinging()
			detach_hook()

# Player movement when not swinging
func player_movement(delta: float) -> void:
	velocity.x = SPEED if Input.is_action_pressed("ui_right") else -SPEED  if Input.is_action_pressed("ui_left") else 0
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_FORCE

func shoot_hook() -> void:
	if not hook_instance:
		hook_instance = hook_scene.instantiate()
		hook_instance.global_position = global_position
		owner.add_child(hook_instance)
		hook_instance.set_player(self)

#swinging mechanic
func restrict_player_distance():
	var direction: Vector2 = global_position - hook_position
	direction = direction.normalized() * length
	global_position = hook_position + direction

func start_swinging() -> void:
	swing_velocity = velocity.length() * sign( hook_position.x - global_position.x) 
	angle = (global_position - hook_position).angle_to(Vector2.DOWN)
	var buffer_vector: Vector2 = Vector2(
		swing_velocity * cos(angle),
		swing_velocity * -sin(angle)
	)
	velocity = buffer_vector * cos(velocity.angle_to(buffer_vector))
	is_swinging = true

func handle_swinging(delta: float) -> void:
	var v_length= velocity.length()
	angle = (global_position - hook_position).angle_to(Vector2.DOWN)
	acceleration = (-gravity * sin(angle))/length * delta * 100
	swing_velocity = sign(swing_velocity) * v_length + acceleration 
	if Input.is_action_just_pressed("space"):
		swing_velocity *= 2
	velocity.x = swing_velocity * cos(angle) 
	velocity.y = swing_velocity * -sin(angle) 

	
	restrict_player_distance()

func stop_swinging() -> void:
	angle = (global_position - hook_position).angle_to(Vector2.DOWN)
	var buffer_vector: Vector2 = Vector2(
		swing_velocity * cos(angle),
		swing_velocity * -sin(angle)
	)
	velocity = buffer_vector
	is_swinging = false

func hook_attached(hook_ref: Area2D)->void:
	is_hook_attached = true
	hook_position = hook_ref.global_position
	length = floor(global_position.distance_to(hook_position)) + 10

func detach_hook() -> void:
	is_hook_attached = false
	if hook_instance:
		hook_instance.queue_free()
		hook_instance = null
