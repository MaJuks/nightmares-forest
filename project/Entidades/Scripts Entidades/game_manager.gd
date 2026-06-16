extends Node
@export var enemy_scenes: Array[PackedScene] = []
@export var spawn_points: Node2D
@export var enemies_label: Label
const ENEMIES_PER_HORDE: int = 5
const ENEMIES_TO_DISPLAY: int = 5
const SPAWN_INTERVAL: float = 1.0
var enemies_spawned: int = 0
var enemies_alive: int = 0
var enemies_killed: int = 0

func _ready() -> void:
	var music = get_parent().get_node_or_null("AudioStreamPlayer2D")
	if music:
		music.volume_db = -80.0
		var tween = create_tween()
		tween.tween_property(music, "volume_db", 0.0, 1.5)
	start_horde()

func start_horde() -> void:
	enemies_spawned = 0
	enemies_alive = 0
	enemies_killed = 0
	update_label()
	spawn_next_enemy()

func spawn_next_enemy() -> void:
	if not is_inside_tree():
		return
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
	if not is_inside_tree():
		return
	enemies_alive -= 1
	enemies_killed += 1
	update_label()
	if enemies_killed >= ENEMIES_TO_DISPLAY and enemies_spawned >= ENEMIES_PER_HORDE:
		horde_complete()

func update_label() -> void:
	if not is_inside_tree():
		return
	if enemies_label:
		var restantes = max(0, ENEMIES_TO_DISPLAY - enemies_killed)
		enemies_label.text = "Inimigos Restantes: " + str(restantes)

func horde_complete() -> void:
	if not is_inside_tree():
		return
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.visible = false
	var music = get_parent().get_node_or_null("AudioStreamPlayer2D")
	if music:
		var tween = create_tween()
		tween.tween_property(music, "volume_db", -80.0, 2.0)
		tween.tween_callback(music.stop)
	await get_tree().create_timer(2.0).timeout
	if not is_inside_tree():
		return
	GameManager.go_to_next_phase()
