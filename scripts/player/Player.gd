#nie dodawac tu dużo kodu, od tego są stejty
extends CharacterBody2D
class_name Player

var speed = 80
var jump_impulse = 360
var gravity = 1200
var acceleration = 60
var friction = 20
var air_friction = 10

func get_input_direction() -> float:
	var input_direction = Input.get_vector("left", "right", "up", "down")
	return input_direction
