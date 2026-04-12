extends Area2D

var bullet_speed := 700.0
var direction := Vector2.RIGHT
var damage := 1

func _ready() -> void:
	global_rotation = direction.angle()

func _process(delta: float) -> void:
	global_position += direction * bullet_speed * delta

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)

	queue_free()
