extends CharacterBody2D

# Constants
const MAX_WALK_SPEED: float = 200
const MAX_RUN_SPEED: float = 400
const MOVE_STRENGTH_ON_FLOOR: float = 80
const MOVE_STRENGTH_IN_AIR: float = 20
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
var is_swinging: bool = false
var angle: float = 0.0
var acceleration: float = 0.0 
var swing_velocity: float = 0.0
var damping_factor: float = 1 


func _physics_process(delta: float) -> void:
	on_floor = is_on_floor()
	process_timers(delta)
	handle_inputs()
	if is_swinging:
		handle_swinging(delta)
		if sqrt(gravity* length) > swing_velocity and global_position.y < hook_position.y:
			is_swinging = false
	elif is_hook_attached:
		player_movement(delta)
		if (global_position - hook_position).length() >= length:
			restrict_player_distance()
			if global_position.y > hook_position.y or sqrt(gravity* length) <= swing_velocity:
				start_swinging()
	else:
		player_movement(delta)
	move_and_slide()
	if Input.is_action_just_pressed("send_hook"):
		shoot_hook()
		if(is_hook_attached):
			stop_swinging()
			detach_hook()

# Player movement when not swinging
func player_movement(delta: float) -> void:
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

	if abs(velocity.x) < move_strength and direction_vector.x == 0: # nie jestem fanem tej linijki ale bez niej czasami gracz sie nie zatrzymuje
		velocity.x = 0

	if space_pressed:
		jump_buffer_counter = JUMP_BUFFER_TIME
		if coyote_time_counter > 0:
			jump()
	if on_floor and jump_buffer_counter > 0:
		jump()

func handle_inputs():
	direction_vector = Input.get_vector("left", "right", "up", "down")
	space_pressed = Input.is_action_pressed("space")
	if Input.is_action_pressed("sprint"):
		max_speed = MAX_RUN_SPEED
	else:
		max_speed = MAX_WALK_SPEED

func jump():
	coyote_time_counter = 0.0
	jump_buffer_counter = 0.0
	velocity.y = -JUMP_STRENGTH

func process_timers(delta: float):
	if on_floor:
		coyote_time_counter = COYOTE_TIME
	if jump_buffer_counter > 0:
		jump_buffer_counter -= delta
	if coyote_time_counter > 0:
		coyote_time_counter -= delta

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
	velocity.x = swing_velocity * cos(angle) 
	velocity.y = swing_velocity * -sin(angle)
	restrict_player_distance()

func stop_swinging() -> void:
	is_swinging = false

func hook_attached(hook_ref: Area2D)->void:
	is_hook_attached = true
	hook_position = hook_ref.global_position
	length = floor(global_position.distance_to(hook_position)) 

func detach_hook() -> void:
	is_hook_attached = false
	if hook_instance:
		hook_instance.queue_free()
		hook_instance = null
