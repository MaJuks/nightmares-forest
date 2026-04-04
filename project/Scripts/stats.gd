extends Resource

class_name Stats

@export var max_health: int = 100
@export var velocity: int = 10
@export var damage: int = 10

var health: int = 0

func _init() -> void:
	health = max_health
