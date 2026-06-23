extends CharacterBody2D

enum enemyOneState {
	WALKING,
	DEAD
}

signal xp_droped(amount: int)

@export var drop_item: PackedScene
@export var fireball_scene: PackedScene
@export var xp_reward: int = 50

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var death_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

const SPEED = 50.0

var max_health: int = 1000
var health: int = max_health
var damage: int = 10
var status: enemyOneState
var player: CharacterBody2D
var next_fireball_health: int = 900
var can_deal_damage: bool = true

func _ready() -> void:
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	player = get_tree().get_first_node_in_group("player")
	go_to_walk_state()

	await get_tree().process_frame

	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show_boss_health(max_health)

func _physics_process(delta: float) -> void:
	match status:
		enemyOneState.WALKING:
			walk_state(delta)
		enemyOneState.DEAD:
			dead_state(delta)

	move_and_slide()

	check_player_collision_damage()

func check_player_collision_damage() -> void:
	if not can_deal_damage:
		return

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()

		if body != null and body.is_in_group("player"):
			var direction = (body.global_position - global_position).normalized()

			body.take_damage(damage, direction)

			can_deal_damage = false
			get_tree().create_timer(1.0).timeout.connect(func(): can_deal_damage = true)
			break

func go_to_walk_state() -> void:
	status = enemyOneState.WALKING
	animated_sprite_2d.play("walking")

func go_to_dead_state() -> void:
	status = enemyOneState.DEAD
	animated_sprite_2d.play("dead")

	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	set_collision_layer(0)
	set_collision_mask(0)

	death_sound.play()

	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.hide_boss_health()

	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		player_node.stats.experience += xp_reward

func walk_state(_delta: float) -> void:
	if player == null:
		return

	var direcao = (player.global_position - global_position).normalized()
	velocity = direcao * SPEED
	animated_sprite_2d.flip_h = direcao.x < 0

func dead_state(_delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, SPEED)

func shoot_fireball() -> void:
	if fireball_scene == null or player == null:
		return

	var fireball = fireball_scene.instantiate()
	get_parent().call_deferred("add_child", fireball)
	fireball.global_position = global_position
	fireball.direction = (player.global_position - global_position).normalized()

func _on_animation_finished() -> void:
	if status == enemyOneState.DEAD:
		if drop_item and randf() <= 0.1:
			var item = drop_item.instantiate()
			get_parent().add_child(item)
			item.global_position = global_position

		queue_free()

func take_damage(damage_amount: int = 1) -> void:
	if status == enemyOneState.DEAD:
		return

	health -= damage_amount

	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.update_boss_health(health, max_health)

	if health <= next_fireball_health:
		next_fireball_health -= 100
		shoot_fireball()

	if health <= 0:
		go_to_dead_state()
