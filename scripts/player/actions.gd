extends Node2D

@onready var hook_instance= preload("res://test stuf/Hook.tscn").instantiate()
var is_hook_attached: bool = false
var hook_position: Vector2 = Vector2.ZERO
var length: float = 0.0

func shoot_hook(global_position: Vector2) -> void:
	if not hook_instance:
		hook_instance.global_position = global_position
		owner.add_child(hook_instance)
		hook_instance.set_player(self)

func attach_hook(hook_ref: Area2D , global_position: Vector2)->Dictionary:
	length = floor(global_position.distance_to(hook_position))
	return {
		hook_position : hook_position,
		length : length
	} 

func detach_hook() -> void:
	is_hook_attached = false
	if hook_instance:
		hook_instance.queue_free()
		hook_instance = null
