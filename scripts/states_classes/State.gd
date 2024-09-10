extends Node
class_name State

var state_machine = null

var entity: CharacterBody2D

func _ready() -> void:
	await owner.ready # w sumie to nie wiem jak to działa ale bez tego ne działa

	entity = owner as CharacterBody2D
	assert(entity != null,"could't find owner in State")

#virtualne funkcje poniżej :)
func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func enter(_msg := {}) -> void:
	pass

func exit() -> void:
	pass
