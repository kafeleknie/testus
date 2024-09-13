extends Area2D

const SPEED: float = 1200
const GRAVITY: float = 800
var velocity: Vector2
var stop: bool = false



func _ready() -> void:
	look_at(get_global_mouse_position())
	velocity = transform.x * SPEED

func _physics_process(delta: float) -> void:
	if not stop:
		# Apply gravity and move the hook
		velocity.y += GRAVITY * delta
		position += velocity * delta
		rotation = velocity.angle()


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		stop = true
