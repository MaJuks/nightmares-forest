extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar  # nome exato do nó

func _ready() -> void:
	add_to_group("hud")

func update_health(cur_health: int, max_health: int) -> void:
	health_bar.max_value = max_health
	health_bar.value = cur_health
