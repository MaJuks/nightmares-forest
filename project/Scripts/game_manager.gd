extends Node

@export var enemy_scene: PackedScene
@export var spawn_points: Node2D
@export var enemies_label: Label

const ENEMIES_PER_HORDE: int = 11
const ENEMIES_TO_DISPLAY: int = 10
const SPAWN_INTERVAL: float = 2.0

var enemies_spawned: int = 0
var enemies_alive: int = 0
var enemies_killed: int = 0

func _ready() -> void:
	start_horde()

func start_horde() -> void:
	enemies_spawned = 0
	enemies_alive = 0
	enemies_killed = 0
	update_label()
	spawn_next_enemy()

func spawn_next_enemy() -> void:
	if enemies_spawned >= ENEMIES_PER_HORDE:
		return

	var points = spawn_points.get_children()
	if points.is_empty():
		return

	var random_point = points[randi() % points.size()]

	var enemy = enemy_scene.instantiate()
	enemy.tree_exited.connect(_on_enemy_died)
	get_parent().add_child(enemy)
	enemy.global_position = random_point.global_position

	enemies_spawned += 1
	enemies_alive += 1

	if enemies_spawned <= ENEMIES_PER_HORDE - 1:
		await get_tree().create_timer(SPAWN_INTERVAL).timeout
		spawn_next_enemy()

func _on_enemy_died() -> void:
	enemies_alive -= 1
	enemies_killed += 1
	update_label()

	if enemies_killed >= ENEMIES_TO_DISPLAY and enemies_spawned >= ENEMIES_PER_HORDE:
		horde_complete()

func update_label() -> void:
	if enemies_label:
		var restantes = max(0, ENEMIES_TO_DISPLAY - enemies_killed)
		enemies_label.text = "Inimigos Restantes: " + str(restantes)

func horde_complete() -> void:
	enemies_label.text = "Noite 1 finalizada!!!"
