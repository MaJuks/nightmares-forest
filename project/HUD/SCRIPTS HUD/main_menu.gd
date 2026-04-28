extends Control

@onready var logo = $logo
@onready var play_button = $playButton

@onready var loading1 = $loading1
@onready var loading2 = $loading2
@onready var loading3 = $loading3



var loading_index := 0
var loading_time := 0.0
var loading_active := false
var logo_final_pos: Vector2
var logo_final_scale: Vector2

func _ready():
	logo_final_pos = logo.position
	logo_final_scale = logo.scale

	logo.position = Vector2(-90, -125)
	logo.scale = Vector2(1, 1)

	play_button.visible = false
	play_button.disabled = false

	loading1.visible = false
	loading2.visible = false
	loading3.visible = false

	animate_intro()


func animate_intro():
	var tween = create_tween()
	tween.tween_interval(3.0)

	tween.tween_property(logo, "position", logo_final_pos, 1.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(logo, "scale", logo_final_scale, 1.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.tween_callback(func():
		play_button.visible = true
	)

func _process(delta):
	if loading_active:
		loading_time += delta

		if loading_time >= 0.3:
			loading_time = 0.0
			loading_index = (loading_index + 1) % 3
			update_loading()


func update_loading():
	loading1.visible = (loading_index == 0)
	loading2.visible = (loading_index == 1)
	loading3.visible = (loading_index == 2)


func _on_play_button_pressed():
	play_button.visible = false
	play_button.disabled = true
	logo.visible = false

	loading_active = true
	loading_index = 0
	update_loading()

	await get_tree().create_timer(3.0).timeout

	# Loading terminou - inicia o fade out da música
	var music = get_node_or_null("AudioStreamPlayer2D")
	if music:
		var tween = create_tween()
		tween.tween_property(music, "volume_db", -80.0, 1.0)

	# Após 1 segundo a playing_music começa
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://Map/map.tscn")
