extends CharacterBody2D

#DEFAULT_MOVEMENT
const DEFAULT_MAX_SPEED: float = 320
const DEFAULT_ACCELERATION: float = 80
const IN_AIR_ACCELERATION: float = 20
const DEFAULT_FRICTION: float = 40
const IN_AIR_FRICTION: float = 5

var acceleration: float = DEFAULT_ACCELERATION
var friction: float = DEFAULT_FRICTION

#JUMP
const JUMP_STRENGTH: float = 500
const COYOTE_TIME = 0.1 #100ms 
const JUMP_BUFFER_TIME = 0.1 #100ms 

var coyote_time_counter: float = 0.0
var jump_buffer_counter:float = 0.0

#DASH
const DEFAULT_DASH_SPEED: float = 1500
const DASH_DURATION: float = 0.1
const DASH_COOLDOWN: float = 1

var is_dashing: bool = false
var dash_duration_counter: float = 0.2
var dash_cooldown_counter: float = 0

#----
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var on_floor: bool = false

#INPUTS
var direction: Vector2 = Vector2.ZERO
var last_direction: float = 1
var space_pressed: bool = false
var dash_action: bool = false

#SWING
var is_swinging:bool = false
var dumping_factor:float = 0.99
var angle: float = 0.0
var swing_acceleration: float = 0.0 
var swing_velocity: float = 0.0

#HOOK
var is_hook_attached:bool = false
var hook_position: Vector2 = Vector2.ZERO
var length: float = 0.0
var hook_scene: PackedScene = preload("res://scenes/entities/player/Hook.tscn")
var hook_instance: Area2D

func _physics_process(delta: float) -> void:
	on_floor = is_on_floor()
	handle_inputs()
	process_timers(delta)

	if(is_swinging):
		handle_swinging(delta)
	else:
		if !on_floor:
			apply_gravity(delta)
		apply_movement()
		jump()
		dash()

	if(is_hook_attached):
		if not should_swing():
			is_swinging = false
		elif not is_swinging:
			is_swinging = true
			start_swinging()
		if on_floor:
			detach_hook()
	
	move_and_slide()


func handle_inputs():
	direction = Input.get_vector("left", "right", "up", "down")
	space_pressed = Input.is_action_pressed("space")
	dash_action = Input.is_action_pressed("dash")

	if ( Input.is_action_just_pressed("hook_action")):
		if is_hook_attached:
			detach_hook()
		else:
			shoot_hook(self)

	if direction.x != 0:
		last_direction = direction.x

#
func process_timers(delta: float) -> void:
	if jump_buffer_counter > 0:
		jump_buffer_counter -= delta
	if coyote_time_counter > 0:
		coyote_time_counter -= delta

	if dash_duration_counter > 0:
		dash_duration_counter -= delta
	if dash_cooldown_counter > 0:
		dash_cooldown_counter -= delta

	if space_pressed:
		jump_buffer_counter = JUMP_BUFFER_TIME
	if on_floor:
		coyote_time_counter = COYOTE_TIME

func apply_gravity(delta: float ) -> void:
	velocity.y += gravity * delta

func apply_movement() -> void:
	if is_dashing:
		velocity.y = 0
		velocity.x = DEFAULT_DASH_SPEED * last_direction
		if dash_duration_counter <= 0:
			is_dashing = false
			velocity.x = 0
		return

	if(on_floor):
		acceleration = DEFAULT_ACCELERATION 
		friction = DEFAULT_FRICTION
	else:
		acceleration = IN_AIR_ACCELERATION
		friction = IN_AIR_FRICTION

	if direction.x != 0 and abs(velocity.x) < DEFAULT_MAX_SPEED:
		velocity.x += direction.x * acceleration
	if velocity.x != 0:
		velocity.x -= friction * sign(velocity.x)
	if abs(velocity.x) < friction:
		velocity.x = 0

func jump() -> bool:
	if((on_floor or coyote_time_counter > 0) and jump_buffer_counter > 0):
		velocity.y = -JUMP_STRENGTH
		coyote_time_counter = 0.0
		jump_buffer_counter = 0.0
		return true
	return false

func dash() -> bool:
	if not is_dashing and dash_cooldown_counter <= 0 and dash_action:
		dash_cooldown_counter = DASH_COOLDOWN
		dash_duration_counter = DASH_DURATION
		is_dashing = true
		return true
	return false

#SWING
func should_swing()->bool:
	if(hook_position.distance_to(global_position) + 1>= length) and (global_position.y > hook_position.y or sqrt(gravity* length) <= swing_velocity):
		return true
	return false

func restrict_player_distance() -> Vector2:
	if(hook_position.distance_to(global_position)> length):
		var direction: Vector2 = global_position - hook_position
		direction = direction.normalized() * length
		return hook_position + direction
	return global_position

func start_swinging() -> void:
	swing_velocity = velocity.length() * sign( hook_position.x - global_position.x) 
	angle = (global_position - hook_position).angle_to(Vector2.DOWN)
	var buffer_vector: Vector2 = Vector2(
		swing_velocity * cos(angle),
		swing_velocity * -sin(angle)
	)
	velocity = buffer_vector * cos(velocity.angle_to(buffer_vector))

func handle_swinging(delta: float) -> void:
	var v_length= velocity.length()
	angle = (global_position - hook_position).angle_to(Vector2.DOWN)
	swing_acceleration = (-gravity * sin(angle)) * delta 
	swing_velocity = sign(swing_velocity) * v_length + swing_acceleration 
	swing_velocity *= dumping_factor
	velocity.x = swing_velocity * cos(angle) 
	velocity.y = -swing_velocity * sin(angle)

#HoOk
func shoot_hook(player_ref:CharacterBody2D) -> void:
	if not hook_instance:
		hook_instance = hook_scene.instantiate()
		hook_instance.global_position = player_ref.global_position
		player_ref.get_parent().add_child(hook_instance)
		hook_instance.set_player(player_ref)

func detach_hook() -> void:
	if hook_instance:
		hook_instance.queue_free()
		hook_instance = null
		is_hook_attached = false
		is_swinging = false

func hook_attached(hook_ref:Area2D)->void:
	hook_position = hook_ref.global_position
	length =floor(hook_position.distance_to(global_position))
	is_hook_attached = true
