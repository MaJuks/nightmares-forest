extends Resource

class_name Stats

enum BuffableStats {
	MAX_HEALTH,
	VELOCITY,
	DAMAGE
}

const BASE_LEVEL_XP: float = 100.0
const UPGRADE_AMOUNT: int = 20

signal health_depleted
signal health_change(cur_health: int, max_health: int)
signal level_up(new_level: int)

@export var base_max_health: int = 100
@export var base_velocity: int = 150
@export var base_damage: int = 10
@export var experience: int = 0: set = _on_experience_set

var level: int: 
	get(): return floor(max(1.0, sqrt(experience / BASE_LEVEL_XP)+ 0.5))
var current_max_health: int = 100
var current_velocity: int = 150
var current_damage: int = 10
var health: int = 0: set = _on_health_set

func _init() -> void:
	setup_stats.call_deferred()

func setup_stats() -> void:
	health = current_max_health
	
	
func apply_upgrade(stat: BuffableStats) -> void:
	match stat:
		BuffableStats.MAX_HEALTH:
			current_max_health += UPGRADE_AMOUNT
			health = current_max_health
		BuffableStats.VELOCITY:
			current_velocity += UPGRADE_AMOUNT
		BuffableStats.DAMAGE:
			current_damage += UPGRADE_AMOUNT
	
func _on_health_set(new_value: int) -> void:
	health = clampi(new_value, 0, current_max_health)
	health_change.emit(health, current_max_health)
	if health <= 0:
		health_depleted.emit()

func _on_experience_set(new_value: int) -> void:
	var old_level: int = level
	experience = new_value
	if old_level != level:
		level_up.emit(level)
