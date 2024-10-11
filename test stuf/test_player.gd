extends CharacterBody2D

# Constants
const MAX_WALK_SPEED: float = 200
const MAX_RUN_SPEED: float = 400
const MOVE_STRENGTH_ON_FLOOR: float = 160
const MOVE_STRENGTH_IN_AIR: float = 80
const FRICTION_ON_FLOOR: float = 40
const FRICTION_IN_AIR: float = 5
const JUMP_STRENGTH: float = 500
const COYOTE_TIME = 0.1 #100ms 
const JUMP_BUFFER_TIME = 0.1 #100ms 

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var max_speed: float = MAX_WALK_SPEED
var move_strength: float = MOVE_STRENGTH_ON_FLOOR
var friction:float = FRICTION_ON_FLOOR
var direction_vector: Vector2 = Vector2.ZERO
var space_pressed: bool = false
var on_floor: bool = false
var coyote_time_counter: float = 0.0
var jump_buffer_counter:float = 0.0

# Hook properties
var hook_scene: PackedScene = preload("res://test stuf/Hook.tscn")
var hook_instance: Area2D
var is_hook_attached: bool = false
var hook_position: Vector2 = Vector2.ZERO
var length: float = 0.0

#swinging properties
var dumping_factor:float = 0.99
var is_swinging: bool = false
var angle: float = 0.0
var acceleration: float = 0.0 
var swing_velocity: float = 0.0
var damping_factor: float = 1 


func _physics_process(delta: float) -> void:
	on_floor = is_on_floor()
	process_timers(delta)
	handle_inputs()

	if is_hook_attached:
		handle_player_movement_when_attached(delta)
	else:
		handle_player_movement(delta)

	move_and_slide()


# Player movement when not swinging
func handle_player_movement(delta: float) -> void:
	apply_gravity(delta)
	apply_movement()
	apply_friction()
	handle_jumping()

# Player movement when swinging
func handle_player_movement_when_attached(delta: float) -> void:
	if on_floor:
		detach_hook()
		return
	if is_swinging:
		handle_swinging(delta)
		if sqrt(gravity* length) > swing_velocity and global_position.y < hook_position.y:
			is_swinging = false
	else:
		handle_player_movement(delta)
		if (global_position - hook_position).length() >= length:
			restrict_player_distance()
			if global_position.y > hook_position.y or sqrt(gravity* length) <= swing_velocity:
				start_swinging()

func apply_gravity(delta: float) -> void:
	if not on_floor:
		velocity.y += gravity * delta
		move_strength = MOVE_STRENGTH_IN_AIR
		friction = FRICTION_IN_AIR
	else:
		move_strength = MOVE_STRENGTH_ON_FLOOR
		friction = FRICTION_ON_FLOOR

func apply_movement() -> void:
	if direction_vector.x != 0 and abs(velocity.x) < max_speed:
		velocity.x += direction_vector.x * move_strength

func apply_friction() -> void:
	if velocity.x != 0:
		velocity.x -= friction * sign(velocity.x)
	if abs(velocity.x) < move_strength and direction_vector.x == 0:
		velocity.x = 0

func handle_inputs():
	direction_vector = Input.get_vector("left", "right", "up", "down")
	space_pressed = Input.is_action_pressed("space")
	if Input.is_action_pressed("sprint"):
		max_speed = MAX_RUN_SPEED
	else:
		max_speed = MAX_WALK_SPEED
	if Input.is_action_just_pressed("hook_action"):
		if is_hook_attached:
			detach_hook()
		else:
			shoot_hook()

func handle_jumping() -> void:
	if space_pressed:
		jump_buffer_counter = JUMP_BUFFER_TIME
		if coyote_time_counter > 0:
			jump()
	if on_floor and jump_buffer_counter > 0:
		jump()

func jump():
	coyote_time_counter = 0.0
	jump_buffer_counter = 0.0
	velocity.y = -JUMP_STRENGTH

func process_timers(delta: float) -> void:
	if on_floor:
		coyote_time_counter = COYOTE_TIME
	else:
		coyote_time_counter = max(coyote_time_counter - delta, 0)
	jump_buffer_counter = max(jump_buffer_counter - delta, 0)

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
	acceleration = (-gravity * sin(angle)) * delta 
	swing_velocity = sign(swing_velocity) * v_length + acceleration 
	swing_velocity *= dumping_factor
	velocity.x = swing_velocity * cos(angle) 
	velocity.y = -swing_velocity * sin(angle)
	restrict_player_distance()

func hook_attached(hook_ref: Area2D)->void:
	is_hook_attached = true
	hook_position = hook_ref.global_position
	length = floor(global_position.distance_to(hook_position)) 

func detach_hook() -> void:
	is_swinging = false
	is_hook_attached = false
	if hook_instance:
		hook_instance.queue_free()
		hook_instance = null
