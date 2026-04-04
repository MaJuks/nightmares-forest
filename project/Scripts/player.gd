extends CharacterBody2D

var input: Vector2 = Vector2.ZERO
var velocidade: float = 130.0
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var weapon = $gun
@export var stats : Stats

func get_input():
	input.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	input.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	input = input.normalized()

func character_movement():
	velocity = input * velocidade
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

#chamado quando o node entra na cena primeira vez
func _ready():
	pass
	

# delta é chamado todo frame
func _physics_process(delta):
	get_input()
	character_movement()
	move_and_slide()
	pass
