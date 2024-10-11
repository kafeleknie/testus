extends CharacterBody2D

#GLOBAL
@onready var BASIC_MOVEMENT = preload("res://scripts/player/basic_movement.gd").new()
@onready var SWINGING = preload("res://scripts/player/swinging.gd").new()
@onready var ACTIONS = preload("res://scripts/player/actions.gd").new()
var on_floor: bool = false

#INPUTS
var direction_vector: Vector2 = Vector2.ZERO
var last_direction: float = 1
var space_pressed: bool = false
var dash_action: bool = false
var hook_action: bool = false

#----
var is_hook_attached: bool = false
var is_swinging: bool = false

func _physics_process(delta: float) -> void:
	on_floor = is_on_floor()
	handle_inputs()
	handle_movement(delta)

	if(hook_action):
		if is_hook_attached:
			ACTIONS.detach_hook()
			is_hook_attached = false
			is_swinging = false
		else:
			ACTIONS.shoot_hook(self)

	move_and_slide()

func handle_inputs():
	direction_vector = Input.get_vector("left", "right", "up", "down")
	space_pressed = Input.is_action_pressed("space")
	dash_action = Input.is_action_pressed("dash")
	hook_action =  Input.is_action_just_pressed("hook_action")

	if direction_vector.x != 0:
		last_direction = direction_vector.x

func handle_movement(delta:float):
	SWINGING.update(velocity,on_floor,global_position)
	BASIC_MOVEMENT.update(velocity,on_floor,global_position)
	BASIC_MOVEMENT.process_timers(delta,space_pressed)

	if is_swinging:
		handle_swinging(delta)
	else:
		handle_basic_movement(delta)

	if is_hook_attached:
		global_position = SWINGING.restrict_player_distance()
		if not SWINGING.should_swing():
			is_swinging = false
		elif not is_swinging:
			is_swinging = true
			SWINGING.start_swinging()

func handle_basic_movement(delta:float):
	if !on_floor:
		BASIC_MOVEMENT.apply_gravity(delta)
	BASIC_MOVEMENT.jump()
	if dash_action:
		BASIC_MOVEMENT.dash(last_direction)
	BASIC_MOVEMENT.apply_movement(direction_vector.x)
	velocity = BASIC_MOVEMENT.velocity

func handle_swinging(delta: float):
	SWINGING.handle_swinging(delta)
	velocity = SWINGING.velocity

func hook_attached(hook_ref:Area2D)->void:
	var hook_position = hook_ref.global_position
	SWINGING.set_hook_position(hook_position)
	is_hook_attached = true
