extends Area2D

const SPEED: float = 1200
const GRAVITY: float = 600

var velocity: Vector2
var is_stuck: bool = false 
var player: CharacterBody2D 

func _ready() -> void:
	look_at(get_global_mouse_position())
	velocity = transform.x * SPEED 

func _physics_process(delta: float) -> void:
	if not is_stuck:
		position += velocity * delta  
		rotation = velocity.angle() 

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"): 
		is_stuck = true
		velocity = Vector2.ZERO  
		if player:
			player.start_swinging(self)

func set_player(player_ref: CharacterBody2D) -> void: # te funkcje wywołuje skrypt gracza 
	player = player_ref
