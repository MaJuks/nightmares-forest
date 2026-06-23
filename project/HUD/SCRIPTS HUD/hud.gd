extends CanvasLayer

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var health_label: Label = $LabelHealthBar
@onready var xp_bar: TextureProgressBar = $XpBar
@onready var boss_health_bar: TextureProgressBar = $BossHealthBar
@onready var boss_health_label: Label = $BossHealthLabel

func _ready() -> void:
	add_to_group("hud")
	if boss_health_bar:
		boss_health_bar.visible = false
	if boss_health_label:
		boss_health_label.visible = false

func update_health(cur_health: int, max_health: int) -> void:
	health_bar.max_value = max_health
	health_bar.value = cur_health
	health_label.text = str(cur_health) + " / " + str(max_health)

func update_xp(progress: float) -> void:
	xp_bar.max_value = 100
	xp_bar.value = progress

func show_boss_health(max_health: int) -> void:
	if boss_health_bar:
		boss_health_bar.max_value = max_health
		boss_health_bar.value = max_health
		boss_health_bar.visible = true
	if boss_health_label:
		boss_health_label.text = str(max_health) + " / " + str(max_health)
		boss_health_label.visible = true

func update_boss_health(cur_health: int, max_health: int) -> void:
	if boss_health_bar:
		boss_health_bar.value = cur_health
	if boss_health_label:
		boss_health_label.text = str(cur_health) + " / " + str(max_health)

func hide_boss_health() -> void:
	if boss_health_bar:
		boss_health_bar.visible = false
	if boss_health_label:
		boss_health_label.visible = false
