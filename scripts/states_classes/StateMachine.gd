extends Node
class_name StateMachine

signal transitioned(state_name: String)

@export var initial_state: NodePath #trzeba ręcznie ustawić w inspektorze :( (jeżeli to problem, to możemy zrobić żeby było losowe <3)
@onready var state: State = get_node(initial_state)

func _ready() -> void:
	await owner.ready
	
	for child in get_children(): # przypisywanie zmiennej state_machine
		child.state_machine = self
	state.enter()

func _process(delta: float) -> void:
	state.update(delta)
	
func _physics_process(delta: float) -> void:
	state.physics_update(delta)


func transition_to(target_state_name: String, msg: Dictionary = {}) -> void: # zmiana stanu
	if not has_node(target_state_name):
		return
	state.exit()
	state = get_node(target_state_name)
	state.enter(msg)
	print(state) #mozna usunąć
	emit_signal("transitioned", state.name)
