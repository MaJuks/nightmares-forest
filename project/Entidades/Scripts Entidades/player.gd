extends CharacterBody2D
var input: Vector2 = Vector2.ZERO
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var weapon = $gun
@export var stats: Stats
@onready var hud = get_tree().get_first_node_in_group("hud")
@onready var vignette = null
var invincible: bool = false
var knockback: Vector2 = Vector2.ZERO
@onready var damage_sounds: Array = [$DamageSound1, $DamageSound2]

func get_input():
	input.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	input.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	input = input.normalized()

func character_movement():
	velocity = input * stats.current_velocity + knockback
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
	if GameManager.player_stats != null:
		stats = GameManager.player_stats
	else:
		GameManager.player_stats = stats
	add_to_group("player")
	stats.health_depleted.connect(_on_health_depleted)
	stats.health_change.connect(_on_health_change)
	stats.level_up.connect(_on_level_up)
	stats.xp_change.connect(_on_xp_change)
	await get_tree().process_frame
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		vignette = hud.get_node("BloodVignette")
		if vignette:
			vignette.modulate.a = 0.0
		hud.update_health(stats.health, stats.current_max_health)
		hud.update_xp(stats.xp_progress())
	_on_health_change(stats.health, stats.current_max_health)
		

func _on_level_up(new_level: int) -> void:
	get_tree().paused = true
	var upgrade_ui = preload("res://HUD/upgradeMenu.tscn").instantiate()
	upgrade_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	upgrade_ui.setup(stats)
	get_tree().root.add_child(upgrade_ui)

func _on_xp_change(progress: float) -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.update_xp(progress)

func _on_health_depleted():
	var camera = $Camera2D
	var cam_pos = camera.global_position
	remove_child(camera)
	get_parent().add_child(camera)
	camera.global_position = cam_pos
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.visible = false
	var death_menu = preload("res://HUD/death_menu.tscn").instantiate()
	get_tree().root.add_child(death_menu)
	queue_free()

func _on_health_change(cur_health: int, max_health: int):
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.update_health(cur_health, max_health)
		if vignette:
			var percent = float(cur_health) / float(max_health)
			var intensity = 0.0

			if percent < 0.5:
				intensity = (0.5 - percent) / 0.5

			vignette.modulate.a = intensity
		
func take_damage(amount: int, knockback_direction: Vector2 = Vector2.ZERO) -> void:
	if invincible:
		return
	stats.health -= amount
	knockback = knockback_direction * 400.0
	# Toca um dos sons aleatoriamente
	damage_sounds[randi() % damage_sounds.size()].play()
	invincible = true
	await get_tree().create_timer(1.0).timeout
	invincible = false
	knockback = Vector2.ZERO

func _physics_process(delta):
	get_input()
	character_movement()
	knockback = knockback.move_toward(Vector2.ZERO, 20.0)
	move_and_slide()

func receber_cura(valor: int):
	stats.health += valor
	if stats.health > stats.current_max_health:
		stats.health = stats.current_max_health
	stats.health_change.emit(stats.health, stats.current_max_health)
