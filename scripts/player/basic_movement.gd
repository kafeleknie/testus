extends Node

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var velocity: Vector2 = Vector2.ZERO
var on_floor: bool = false
var global_position: Vector2 = Vector2.ZERO

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
var renew_dash: bool = false
var dash_duration_counter: float = 0
var dash_cooldown_counter: float = 0
var dash_direction: float = 0

func update( player_velocity:Vector2 , player_on_floor:bool , player_global_position: Vector2) -> void:
	global_position = player_global_position
	velocity = player_velocity
	on_floor = player_on_floor

func process_timers(delta: float ,space_pressed: bool) -> void:
	if jump_buffer_counter > 0:
		jump_buffer_counter -= delta
	if coyote_time_counter > 0:
		coyote_time_counter -= delta

	if dash_duration_counter > 0:
		dash_duration_counter -= delta
	if dash_cooldown_counter > 0 and renew_dash:
		dash_cooldown_counter -= delta

	if space_pressed:
		jump_buffer_counter = JUMP_BUFFER_TIME
	if on_floor:
		renew_dash = true
		coyote_time_counter = COYOTE_TIME

func apply_gravity(delta: float ) -> void:
	velocity.y += gravity * delta

func apply_movement(direction: float) -> void:
	if is_dashing:
		velocity.y = 0
		velocity.x = DEFAULT_DASH_SPEED * dash_direction
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

	if direction != 0 and abs(velocity.x) < DEFAULT_MAX_SPEED:
		velocity.x += direction * acceleration
	if velocity.x != 0:
		velocity.x -= friction * sign(velocity.x)
	if abs(velocity.x) < friction:
		velocity.x = 0

func handle_jump_and_dash(direction:float , dash_action: bool) -> void:
	if((on_floor or coyote_time_counter > 0) and jump_buffer_counter > 0):
		jump()
	if dash_action and is_dash_available():
		dash(direction)

func jump() -> void:
	velocity.y = -JUMP_STRENGTH
	coyote_time_counter = 0.0
	jump_buffer_counter = 0.0

func dash(direction:float) -> void:
	dash_direction = direction
	dash_cooldown_counter = DASH_COOLDOWN
	dash_duration_counter = DASH_DURATION
	is_dashing = true
	renew_dash = false

func is_dash_available()->bool:
	if not is_dashing and dash_cooldown_counter <= 0:
		return true
	return false
