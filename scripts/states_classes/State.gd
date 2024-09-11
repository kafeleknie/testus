extends Node
class_name State

var state_machine = null #to jest ustawiane automatycznie przez StateMachine

var entity: CharacterBody2D #węzeł główny bytu do którego nalezy state

func _ready() -> void:
	await owner.ready # w sumie to nie wiem jak to działa ale bez tego ne działa

	entity = owner as CharacterBody2D
	assert(entity != null,"could't find owner in State") # zabezpieczenie

#klasa dziedzicząca state może korzystać z funckji poniżej, wystarczy dodać im zawartość tzn. stworzyć nową funkcje z taką samą nazwą
#nie trzeba używac wszystkich
func update(_delta: float) -> void: # funkcja wykonująca się podczas każdej klatki
	pass

func physics_update(_delta: float) -> void: # funkcja wykonująca się ileś razy w trakcie sekundy(chyba 60)
	pass

func enter(_msg := {}) -> void: # funckja wykonująca się po aktywowaniu stanu
	pass

func exit() -> void: # funckja wykonująca się po wyłączeniu stanu
	pass
