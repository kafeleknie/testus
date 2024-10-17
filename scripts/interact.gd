extends Node2D

@onready var player: CharacterBody2D =$CharacterBody2D
@onready var interactableObject: Node2D =$InteractableObject

func _input(ev):
	if Input.is_action_pressed("Interact"):
		if position.distance_to(player.position)<1000:
			interactableObject.functionality()
