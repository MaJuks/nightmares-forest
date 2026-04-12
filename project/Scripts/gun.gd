extends Area2D

const BULLET_SCENE = preload("res://prefb/bullet.tscn")

@onready var sprite = $anim
@onready var muzzle_right = $MuzzleRight
@onready var muzzle_left = $MuzzleLeft

var shooting := false
var fire_rate := 0.12
var facing_left := false

func _ready() -> void:
	sprite.play("idle_right")

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
func shoot_bullet() -> void:
	var bullet_instance = BULLET_SCENE.instantiate()

	var muzzle = muzzle_right
	if facing_left:
		muzzle = muzzle_left

	var muzzle_pos = muzzle.global_position

	bullet_instance.global_position = muzzle_pos
	bullet_instance.direction = (get_global_mouse_position() - muzzle_pos).normalized()

	get_tree().root.add_child(bullet_instance)
