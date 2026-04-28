extends CharacterBody2D

enum enemyOneState {
	WALKING,
	DEAD
}

signal xp_droped(amount: int)

@export var drop_item: PackedScene
@export var xp_reward: int = 50
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var health_bar: ProgressBar = $ProgressBar

const SPEED = 100.0

var max_health: int = 14
var health: int = max_health
var damage: int = 10
var status: enemyOneState
var player: CharacterBody2D

func _ready() -> void:
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	player = get_tree().get_first_node_in_group("player")
	health_bar.max_value = max_health
	health_bar.value = health
	hitbox.body_entered.connect(_on_damage_area_body_entered)
	go_to_walk_state()

func _on_damage_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.take_damage(damage)

func _physics_process(delta: float) -> void:
	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("player"):
			body.take_damage(damage)
	match status:
		enemyOneState.WALKING:
			walk_state(delta)
		enemyOneState.DEAD:
			dead_state(delta)

	move_and_slide()

func go_to_walk_state() -> void:
	status = enemyOneState.WALKING
	animated_sprite_2d.play("walking")

func go_to_dead_state() -> void:
	status = enemyOneState.DEAD
	animated_sprite_2d.play("dead")
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	
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

func _on_animation_finished() -> void:
	if status == enemyOneState.DEAD:
		if drop_item and randf() <= 0.1:
			var item = drop_item.instantiate()
			get_parent().add_child(item)
			item.global_position = global_position
		queue_free()

func take_damage(damage: int = 1) -> void:
	if status == enemyOneState.DEAD:
		return

	health -= damage
	health_bar.value = health

	if health <= 0:
		go_to_dead_state()
