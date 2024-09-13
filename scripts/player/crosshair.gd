extends Node2D

@onready var hook = preload("res://scenes/entities/player/Hook.tscn")

func _physics_process(delta: float) -> void:
	look_at(get_global_mouse_position())
	var hook_instance = hook.instantiate()
	if Input.is_action_just_pressed("send_hook"):
		hook_instance.position = owner.position
		owner.get_parent().add_child(hook_instance)
