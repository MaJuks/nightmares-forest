extends CharacterBody2D

enum inimigo1State{
	walk,
	dead
}

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var status: inimigo1State

func _ready() -> void:
	go_to_walk_state
	
func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta
		
		match status:
			inimigo1State.walk:
				walk_state(delta)
			inimigo1State.dead:
				dead_state(delta)

	move_and_slide()

func go_to_walk_state():
	status = inimigo1State.walk
	animated_sprite_2d.play("andando")
	
func go_to_dead_state():
	status = inimigo1State.dead
	animated_sprite_2d.play("morto")
	
func walk_state(_delta):
	pass
	
func dead_state(_delta):
	pass
