extends Node2D

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var velocity: Vector2 = Vector2.ZERO
var on_floor: bool = false

#swinging properties
var dumping_factor:float = 0.99
var angle: float = 0.0
var acceleration: float = 0.0 
var swing_velocity: float = 0.0
var damping_factor: float = 1 

func update( player_velocity:Vector2 , player_on_floor:bool) -> void:
	velocity = player_velocity
	on_floor = player_on_floor

func restrict_player_distance(hook_position: Vector2 , length: float):
	var direction: Vector2 = global_position - hook_position
	direction = direction.normalized() * length
	global_position = hook_position + direction

func start_swinging(hook_position: Vector2) -> void:
	swing_velocity = velocity.length() * sign( hook_position.x - global_position.x) 
	angle = (global_position - hook_position).angle_to(Vector2.DOWN)
	var buffer_vector: Vector2 = Vector2(
		swing_velocity * cos(angle),
		swing_velocity * -sin(angle)
	)
	velocity = buffer_vector * cos(velocity.angle_to(buffer_vector))

func handle_swinging(delta: float,hook_position: Vector2) -> void:
	var v_length= velocity.length()
	angle = (global_position - hook_position).angle_to(Vector2.DOWN)
	acceleration = (-gravity * sin(angle)) * delta 
	swing_velocity = sign(swing_velocity) * v_length + acceleration 
	swing_velocity *= dumping_factor
	velocity.x = swing_velocity * cos(angle) 
	velocity.y = -swing_velocity * sin(angle)
