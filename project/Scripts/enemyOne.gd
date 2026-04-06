extends CharacterBody2D

enum enemyOneState {
	WALKING,
	DEAD
}

@export var drop_item: PackedScene
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox

const SPEED = 100.0
var max_health: int = 3
var health: int = max_health

var status: enemyOneState
var player: CharacterBody2D

func _ready() -> void:
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	player = get_tree().get_first_node_in_group("player")
	go_to_walk_state()

func _physics_process(delta: float) -> void:
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

	if drop_item:
		var item = drop_item.instantiate()
		item.global_position = global_position
		get_parent().add_child(item)

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
		queue_free()

func take_damage(damage: int = 1) -> void:
	if status == enemyOneState.DEAD:
		return

	health -= damage

	if health <= 0:
		go_to_dead_state()
