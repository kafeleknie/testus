#nie dodawac tu dużo kodu, od tego są stejty
extends CharacterBody2D

var speed = 200
var jump_impulse = 360
var gravity = 1200
var acceleration = 60
var friction = 20
var air_friction = 10

func get_input_direction() -> Vector2:
	var input_direction:Vector2 = Input.get_vector("left", "right", "up", "down")
	return input_direction

func _process(delta: float) -> void:
	move_and_slide()
