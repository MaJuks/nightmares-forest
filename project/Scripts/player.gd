extends CharacterBody2D

var input: Vector2 = Vector2.ZERO
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var weapon = $gun
@export var stats: Stats
var invincible: bool = false

# REMOVIDO: var velocidade e var health — agora vêm direto do stats

func get_input():
	input.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	input.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	input = input.normalized()

func character_movement():
	# Lê a velocidade dinamicamente a cada frame
	velocity = input * stats.current_velocity
	if input.x > 0:
		anim.play("walking")
		anim.flip_h = false
		weapon.z_index = 2
	elif input.x < 0:
		anim.play("walking")
		anim.flip_h = true
		weapon.z_index = 2
	elif input.y < 0:
		anim.play("walking_up")
		anim.flip_h = true
		weapon.z_index = 0
	elif input.y > 0:
		anim.play("walking_down")
		anim.flip_h = false
		weapon.z_index = 2
	else:
		anim.play("standing")
		weapon.z_index = 2

func _ready():
	add_to_group("player")
	# Conecta os sinais do Stats
	stats.health_depleted.connect(_on_health_depleted)
	stats.health_change.connect(_on_health_change)
	stats.level_up.connect(_on_level_up)
	var hud = get_tree().get_first_node_in_group("canvas_layer")
	if hud:
		hud.update_health(stats.health, stats.current_max_health)
	
func _on_level_up(new_level: int) -> void:
	get_tree().paused = true
	var upgrade_ui = preload("res://Entidades/upgradeMenu.tscn").instantiate()
	upgrade_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	upgrade_ui.setup(stats)	
	get_tree().root.add_child(upgrade_ui)

func _on_health_depleted():
	# Lógica de morte do player aqui
	queue_free()

func _on_health_change(cur_health: int, max_health: int):
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.update_health(cur_health, max_health)
	pass
	
func take_damage(amount: int) -> void:
	if invincible:
		return
	stats.health -= amount
	invincible = true
	await get_tree().create_timer(1.0).timeout
	invincible = false

func _physics_process(delta):
	get_input()
	character_movement()
	move_and_slide()
