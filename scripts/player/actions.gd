extends Node

var hook_scene: PackedScene = preload("res://scenes/entities/player/Hook.tscn")
var hook_instance: Area2D

func shoot_hook(player_ref:CharacterBody2D) -> void:
	if not hook_instance:
		hook_instance = hook_scene.instantiate()
		hook_instance.global_position = player_ref.global_position
		player_ref.get_parent().add_child(hook_instance)
		hook_instance.set_player(player_ref)

func detach_hook() -> void:
	if hook_instance:
		hook_instance.queue_free()
		hook_instance = null
