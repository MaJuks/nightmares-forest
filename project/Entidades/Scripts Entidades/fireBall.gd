extends Area2D

var direction: Vector2 = Vector2.ZERO
var speed: float = 600.0
var damage: int = 20

func _ready() -> void:
	await get_tree().create_timer(5.0).timeout
	if is_instance_valid(self):
		queue_free()

func _process(delta: float) -> void:
	global_position += direction * speed * delta
	global_rotation = direction.angle() - PI / 2

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.take_damage(damage)
	queue_free()
