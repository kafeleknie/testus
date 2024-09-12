extends CharacterBody2D

const MAX_WALK_SPEED: float = 200
const MAX_RUN_SPEED: float = 400
const MOVE_STRENGTH_ON_FLOOR: float = 80
const MOVE_STRENGTH_IN_AIR: float = 20
const FRICTION_ON_FLOOR: float = 40
const FRICTION_IN_AIR: float = 5
const JUMP_STRENGTH: float = 500
const COYOTE_TIME = 0.2 # 200 ms 
const JUMP_BUFFER_TIME = 0.2 # 200 ms 

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity");

var max_speed: float = MAX_WALK_SPEED
var move_strength: float = MOVE_STRENGTH_ON_FLOOR
var friction:float = FRICTION_ON_FLOOR
var direction_vector: Vector2 = Vector2.ZERO
var space_pressed: bool = false
var on_floor: bool = false
var coyote_time_counter: float = 0.0
var jump_buffer_counter:float = 0.0

enum STATES{WALK, RUN, IDLE}
var state: STATES = STATES.IDLE

func handle_inputs():
	direction_vector = Input.get_vector("left", "right", "up", "down")
	space_pressed = Input.is_action_pressed("space")
	if Input.is_action_pressed("sprint"):
		max_speed = MAX_RUN_SPEED
	else:
		max_speed = MAX_WALK_SPEED

func process_timers(delta: float):
	if on_floor:
		coyote_time_counter = COYOTE_TIME
	if jump_buffer_counter > 0:
		jump_buffer_counter -= delta
	if coyote_time_counter > 0:
		coyote_time_counter -= delta

func jump():
	coyote_time_counter = 0.0
	jump_buffer_counter = 0.0
	velocity.y = -JUMP_STRENGTH

func _process(delta: float):
	on_floor = is_on_floor()
	process_timers(delta)
	handle_inputs()
	if not on_floor:
		velocity.y += gravity * delta
		move_strength = MOVE_STRENGTH_IN_AIR
		friction = FRICTION_IN_AIR
	else:
		move_strength = MOVE_STRENGTH_ON_FLOOR
		friction = FRICTION_ON_FLOOR

	if direction_vector.x != 0 and abs(velocity.x) <= max_speed:
		velocity.x += direction_vector.x * move_strength
	if velocity.x != 0:
		velocity.x += friction if velocity.x < 0 else -friction

	if space_pressed:
		jump_buffer_counter = JUMP_BUFFER_TIME
		if coyote_time_counter > 0:
			jump()
	if on_floor and jump_buffer_counter > 0:
		jump()

	move_and_slide()
