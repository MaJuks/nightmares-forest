extends Node

@export var enemy_scenes: Array[PackedScene] = []
@export var spawn_points: Node2D
@export var enemies_label: Label

const ENEMIES_PER_HORDE: int = 50
const ENEMIES_TO_DISPLAY: int = 50
const SPAWN_INTERVAL: float = 1.0

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
	if points.is_empty() or enemy_scenes.is_empty():
		return

	var random_point = points[randi() % points.size()]
	var random_scene = enemy_scenes[randi() % enemy_scenes.size()]

	var enemy = random_scene.instantiate()
	enemy.tree_exited.connect(_on_enemy_died)
	get_parent().add_child.call_deferred(enemy)
	enemy.global_position = random_point.global_position

	enemies_spawned += 1
	enemies_alive += 1

	if enemies_spawned <= ENEMIES_PER_HORDE - 1:
		await get_tree().create_timer(SPAWN_INTERVAL, false).timeout
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
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.visible = false
	#enemies_label.text = "Noite 1 finalizada!!!" linha desativada para mostrar final na apresentação
	var end = preload("res://HUD/End.tscn").instantiate()
	get_tree().root.add_child(end)
	
