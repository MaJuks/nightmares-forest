extends CharacterBody2D

enum enemyState {
	IDLE,
	WALKING,
	SHOOTING,
	DEAD
}

signal xp_droped(amount: int)

@export var drop_item: PackedScene
@export var projectile_scene: PackedScene
@export var xp_reward: int = 150
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var health_bar: ProgressBar = $ProgressBar
@onready var shoot_timer: Timer = $ShootTimer

const SPEED = 70.0
const SHOOT_RANGE = 300.0
const RETREAT_RANGE = 120.0

var max_health: int = 4
var health: int = max_health
var damage: int = 8
var status: enemyState
var player: CharacterBody2D

func _ready() -> void:
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	player = get_tree().get_first_node_in_group("player")
	health_bar.max_value = max_health
	health_bar.value = health
	hitbox.body_entered.connect(_on_damage_area_body_entered)
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	go_to_walk_state()

func _on_damage_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.take_damage(damage)

func _physics_process(delta: float) -> void:
	match status:
		enemyState.IDLE:
			idle_state(delta)
		enemyState.WALKING:
			walk_state(delta)
		enemyState.SHOOTING:
			shoot_state(delta)
		enemyState.DEAD:
			dead_state(delta)

	move_and_slide()

func go_to_walk_state() -> void:
	status = enemyState.WALKING
	animated_sprite_2d.play("run")
	shoot_timer.stop()

func go_to_idle_state() -> void:
	status = enemyState.SHOOTING
	animated_sprite_2d.play("idle")
	if shoot_timer.is_stopped():
		shoot_timer.start()

func go_to_dead_state() -> void:
	status = enemyState.DEAD
	animated_sprite_2d.stop()
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	shoot_timer.stop()
	velocity = Vector2.ZERO

	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		player_node.stats.experience += xp_reward

	await get_tree().create_timer(0.4).timeout
	if not is_instance_valid(self):
		return
	if drop_item and randf() <= 0.1:
		var item = drop_item.instantiate()
		get_parent().add_child(item)
		item.global_position = global_position
	queue_free()

func _get_distance_to_player() -> float:
	if player == null:
		return INF
	return global_position.distance_to(player.global_position)

func _face_player() -> void:
	if player == null:
		return
	animated_sprite_2d.flip_h = player.global_position.x < global_position.x

func idle_state(_delta: float) -> void:
	velocity = Vector2.ZERO

func walk_state(_delta: float) -> void:
	if player == null:
		return

	var distance = _get_distance_to_player()
	var direcao = (player.global_position - global_position).normalized()

	if distance < RETREAT_RANGE:
		velocity = -direcao * SPEED
	elif distance > SHOOT_RANGE:
		velocity = direcao * SPEED
	else:
		velocity = Vector2.ZERO
		go_to_idle_state()
		return

	_face_player()

func shoot_state(_delta: float) -> void:
	if player == null:
		return

	velocity = Vector2.ZERO
	var distance = _get_distance_to_player()
	_face_player()

	if distance > SHOOT_RANGE or distance < RETREAT_RANGE:
		go_to_walk_state()

func dead_state(_delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, SPEED)

func _on_shoot_timer_timeout() -> void:
	if status != enemyState.SHOOTING or player == null or projectile_scene == null:
		return

	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	projectile.global_position = global_position
	projectile.direction = (player.global_position - global_position).normalized()

func _on_animation_finished() -> void:
	pass

func take_damage(damage_amount: int = 1) -> void:
	if status == enemyState.DEAD:
		return

	health -= damage_amount
	health_bar.value = health

	if health <= 0:
		go_to_dead_state()
