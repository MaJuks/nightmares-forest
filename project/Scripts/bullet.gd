extends Area2D

var bullet_speed := 700.0
var direction := Vector2.RIGHT

func _ready() -> void:
	rotation = direction.angle()

func _process(delta: float) -> void:
	global_position += direction * bullet_speed * delta
