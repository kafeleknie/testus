extends CharacterBody2D

#GLOBAL
@onready var movement = preload("res://scripts/player/movement.gd").new()
var on_floor: bool = false

#INPUTS
var direction_vector: Vector2 = Vector2.ZERO
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

func handle_movement(delta:float):
	movement.process_timers(delta,space_pressed)
	if movement.update(velocity,on_floor):
		if not on_floor:
			movement.apply_gravity(delta)
		movement.jump()
		movement.apply_movement(direction_vector.x)
		if dash_action:
			movement.dash(direction_vector.x)
		velocity = movement.velocity
