extends Node

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var velocity: Vector2 = Vector2.ZERO
var on_floor: bool = false
var global_position: Vector2 = Vector2.ZERO

#swinging properties
var dumping_factor:float = 0.99
var angle: float = 0.0
var acceleration: float = 0.0 
var swing_velocity: float = 0.0

#
var hook_position: Vector2 = Vector2.ZERO
var length: float = 0.0

func update( player_velocity:Vector2 , player_on_floor:bool , player_global_position: Vector2) -> void:
	global_position = player_global_position
	velocity = player_velocity
	on_floor = player_on_floor

func set_hook_position(h_position:Vector2)->void:
	hook_position = h_position
	length =floor(hook_position.distance_to(global_position))

func should_swing()->bool:
	if(hook_position.distance_to(global_position) + 1>= length) and (global_position.y > hook_position.y or sqrt(gravity* length) <= swing_velocity):
		return true
	return false

func restrict_player_distance() -> Vector2:
	if(hook_position.distance_to(global_position)> length):
		var direction: Vector2 = global_position - hook_position
		direction = direction.normalized() * length
		return hook_position + direction
	return global_position

func start_swinging() -> void:
	swing_velocity = velocity.length() * sign( hook_position.x - global_position.x) 
	angle = (global_position - hook_position).angle_to(Vector2.DOWN)
	var buffer_vector: Vector2 = Vector2(
		swing_velocity * cos(angle),
		swing_velocity * -sin(angle)
	)
	velocity = buffer_vector * cos(velocity.angle_to(buffer_vector))

func handle_swinging(delta: float) -> void:
	var v_length= velocity.length()
	angle = (global_position - hook_position).angle_to(Vector2.DOWN)
	acceleration = (-gravity * sin(angle)) * delta 
	swing_velocity = sign(swing_velocity) * v_length + acceleration 
	swing_velocity *= dumping_factor
	velocity.x = swing_velocity * cos(angle) 
	velocity.y = -swing_velocity * sin(angle)
