extends Node2D

@onready var player: CharacterBody2D =$"../CharacterBody2D"

func functionality():
	player.addToInventory($".")
