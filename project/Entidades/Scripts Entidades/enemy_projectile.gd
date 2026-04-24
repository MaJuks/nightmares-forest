extends Area2D

var speed: float = 250.0
var direction: Vector2 = Vector2.RIGHT
var damage: int = 10
var lifetime: float = 3.0

func _ready() -> void:
	global_rotation = direction.angle()
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(lifetime).timeout
	if is_instance_valid(self):
		queue_free()

func _process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
