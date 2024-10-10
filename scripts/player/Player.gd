extends CharacterBody2D

#GLOBAL
@onready var BASIC_MOVEMENT = preload("res://scripts/player/basic_movement.gd").new()
var on_floor: bool = false

#INPUTS
var direction_vector: Vector2 = Vector2.ZERO
var last_direction: float = 1
var space_pressed: bool = false
var dash_action: bool = false
var hook_action: bool = false

func _physics_process(delta: float) -> void:
	on_floor = is_on_floor()
	handle_inputs()
	handle_movement(delta)

	move_and_slide()

func handle_inputs():
	direction_vector = Input.get_vector("left", "right", "up", "down")
	space_pressed = Input.is_action_pressed("space")
	dash_action = Input.is_action_pressed("dash")
	hook_action =  Input.is_action_just_pressed("hook_action")

	if direction_vector.x != 0:
		last_direction = direction_vector.x

func handle_movement(delta:float):
	handle_basic_movement(delta)

func handle_basic_movement(delta:float):
	BASIC_MOVEMENT.process_timers(delta,space_pressed)
	BASIC_MOVEMENT.update(velocity,on_floor)
	if !on_floor:
		BASIC_MOVEMENT.apply_gravity(delta)
	BASIC_MOVEMENT.jump()
	if dash_action:
		BASIC_MOVEMENT.dash(last_direction)
	BASIC_MOVEMENT.apply_movement(direction_vector.x)
	velocity = BASIC_MOVEMENT.velocity

func handle_advanced_movement(delta: float):
	pass
