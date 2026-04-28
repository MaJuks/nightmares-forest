extends Area2D

const BULLET_SCENE = preload("res://Entidades/bullet.tscn")

@onready var sprite = $anim
@onready var muzzle_right = $MuzzleRight
@onready var muzzle_left = $MuzzleLeft
@onready var light_right = $MuzzleRight/PointLight2D  # ← novo
@onready var light_left = $MuzzleLeft/PointLight2D    # ← novo


var shooting := false
var fire_rate := 0.12
var facing_left := false
var flash_tween: Tween  # ← novo

func _ready() -> void:
	sprite.play("idle_right")
	
	light_right.visible = false
	light_left.visible = false

func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var dir = mouse_pos - global_position

	facing_left = dir.x < 0

	if facing_left:
		rotation = dir.angle() + PI
	else:
		rotation = dir.angle()

	if not shooting:
		if facing_left:
			sprite.play("idle_left")
		else:
			sprite.play("idle_right")

	if Input.is_action_pressed("shoot") and not shooting:
		start_shooting()

	if not Input.is_action_pressed("shoot") and shooting:
		stop_shooting()

var _shoot_loop_id := 0

func start_shooting() -> void:
	if shooting:
		return
	shooting = true
	_shoot_loop_id += 1
	var my_id = _shoot_loop_id

	if facing_left:
		sprite.play("shoot_left")
	else:
		sprite.play("shoot_right")
	sprite.speed_scale = 5.0

	while shooting and _shoot_loop_id == my_id:
		shoot_bullet()
		await get_tree().create_timer(fire_rate, false).timeout

func stop_shooting() -> void:
	shooting = false
	sprite.speed_scale = 1.0
	if facing_left:
		sprite.play("idle_left")
	else:
		sprite.play("idle_right")
		
func flash_muzzle_light() -> void:
	var light = light_left if facing_left else light_right
	

	if flash_tween:
		flash_tween.kill()
	

	var other_light = light_right if facing_left else light_left
	other_light.visible = false
	

	light.visible = true
	light.energy = 1.5
	

	flash_tween = create_tween()
	flash_tween.tween_property(light, "energy", 0.0, 0.5)
	flash_tween.tween_callback(func(): light.visible = false)
		
func shoot_bullet() -> void:
	var bullet_instance = BULLET_SCENE.instantiate()
	var muzzle = muzzle_right
	if facing_left:
		muzzle = muzzle_left
	var muzzle_pos = muzzle.global_position
	bullet_instance.global_position = muzzle_pos
	bullet_instance.direction = (get_global_mouse_position() - muzzle_pos).normalized()
	
	# Pega o dano do stats do player
	var player = get_tree().get_first_node_in_group("player")
	if player:
		bullet_instance.damage = player.stats.current_damage  # ← novo
	
	get_tree().root.add_child(bullet_instance)
	flash_muzzle_light()
	
