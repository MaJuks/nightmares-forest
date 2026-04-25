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

func start_shooting() -> void:
	shooting = true
	sprite.speed_scale = 5.0

	if facing_left:
		sprite.play("shoot_left")
	else:
		sprite.play("shoot_right")

	while shooting:
		shoot_bullet()
		await get_tree().create_timer(fire_rate).timeout

func stop_shooting() -> void:
	shooting = false
	sprite.speed_scale = 1.0

	if facing_left:
		sprite.play("idle_left")
	else:
		sprite.play("idle_right")
		
func flash_muzzle_light() -> void:
	# Escolhe a luz certa baseado na direção
	var light = light_left if facing_left else light_right
	
	# Cancela flash anterior se ainda estiver rodando
	if flash_tween:
		flash_tween.kill()
	
	# Apaga a luz errada (caso tenha ficado ligada)
	var other_light = light_right if facing_left else light_left
	other_light.visible = false
	
	# Acende com energia máxima
	light.visible = true
	light.energy = 1.5
	
	# Fade out suave
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

	get_tree().root.add_child(bullet_instance)
	
	flash_muzzle_light()  # ← chama o flash aqui
	
