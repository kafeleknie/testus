extends Control

var coinsValue=0
@onready var coins: Label = %Coins

func _on_button_pressed():
	coinsValue+=1
	print(coinsValue)
	coins.text=str(coinsValue)
