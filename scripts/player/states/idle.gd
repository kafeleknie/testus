extends State

func update(delta: float) -> void:
	var direction:Vector2 = entity.get_input_direction();
	entity.velocity = entity.get_input_direction();

	if(direction.x != 0):
		state_machine.transition_to("Run")
