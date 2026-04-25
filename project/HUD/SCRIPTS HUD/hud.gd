extends CanvasLayer

@onready var health_bar: TextureProgressBar = $HealthBar  #
@onready var health_label: Label = $LabelHealthBar
@onready var xp_bar: TextureProgressBar = $XpBar  #

func _ready() -> void:
	add_to_group("hud")

func update_health(cur_health: int, max_health: int) -> void:
	health_bar.max_value = max_health
	health_bar.value = cur_health
	health_label.text =str(cur_health) + " / " + str(max_health)

func update_xp(progress: float) -> void:
	xp_bar.max_value = 100
	xp_bar.value = progress
