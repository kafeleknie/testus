extends Node

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var velocity: Vector2 = Vector2.ZERO
var on_floor: bool = false

#DEFAULT_MOVEMENT
const DEFAULT_MAX_SPEED: float = 320
const DEFAULT_ACCELERATION: float = 60
const IN_AIR_ACCELERATION: float = 10
const DEFAULT_FRICTION: float = 20
const IN_AIR_FRICTION: float = 2

var acceleration: float = DEFAULT_ACCELERATION
var friction: float = DEFAULT_FRICTION

#JUMP
const JUMP_STRENGTH: float = 500
const COYOTE_TIME = 0.1 #100ms 
const JUMP_BUFFER_TIME = 0.1 #100ms 

var coyote_time_counter: float = 0.0
var jump_buffer_counter:float = 0.0

#DASH
const DASH_SPEED: float = 1000
const DASH_DURATION: float = 0.2
const DASH_COOLDOWN: float = 1.0

var is_dashing: bool = false
var dash_cooldown_timer: float = 0
var dash_duration_timer: float = 0
var dash_buffer: bool = false


func update(main_velocity:Vector2 , main_on_floor:bool) -> bool:
	velocity = main_velocity
	on_floor = main_on_floor
	if is_dashing:
		return false
	return true

func process_timers(delta: float ,space_pressed: bool) -> void:
	if jump_buffer_counter > 0:
		jump_buffer_counter -= delta
	if coyote_time_counter > 0:
		coyote_time_counter -= delta
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	if dash_duration_timer > 0:
		dash_duration_timer -= delta
	else:
		is_dashing = false

	if space_pressed:
		jump_buffer_counter = JUMP_BUFFER_TIME
	if on_floor:
		coyote_time_counter = COYOTE_TIME

func apply_gravity(delta: float ) -> void:
	velocity.y += gravity * delta

func apply_movement(direction: float) -> void:
	if dash_buffer:
		velocity.x = 0
		dash_buffer = false
	
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

func jump() -> void:
	if((on_floor or coyote_time_counter > 0) and jump_buffer_counter > 0):
		velocity.y = -JUMP_STRENGTH
		coyote_time_counter = 0.0
		jump_buffer_counter = 0.0

func dash(direction: float) -> void:
	if dash_cooldown_timer <= 0:
		dash_buffer = true
		dash_cooldown_timer = DASH_COOLDOWN
		dash_duration_timer = DASH_DURATION
		velocity.x = DASH_SPEED * direction
