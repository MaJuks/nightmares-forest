extends CanvasLayer

var stats: Stats

func _ready() -> void:
	add_to_group("upgrade_menu")
	
func setup(player_stats: Stats) -> void:
	stats = player_stats

func _on_health_button_pressed() -> void:
	stats.apply_upgrade(Stats.BuffableStats.MAX_HEALTH)
	_close()

func _on_velocity_button_pressed() -> void:
	stats.apply_upgrade(Stats.BuffableStats.VELOCITY)
	_close()

func _on_damage_button_pressed() -> void:
	stats.apply_upgrade(Stats.BuffableStats.DAMAGE)
	_close()

func _close() -> void:
	get_tree().paused = false
	queue_free()
