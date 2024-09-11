extends State

func update(delta: float) -> void:
	var direction: Vector2 = entity.get_input_direction();

	entity.velocity.y += entity.gravity * delta
	entity.velocity.x = direction.x * entity.speed
	if(entity.velocity.x ==0 ):
		state_machine.transition_to("Idle")
