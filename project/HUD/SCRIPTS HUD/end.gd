extends CanvasLayer

func _ready() -> void:
	$Label.modulate.a = 0
	$ColorRect.modulate.a = 0

	var tween = create_tween()
	tween.tween_property($ColorRect, "modulate:a", 1.0, 2.0)
	tween.tween_interval(0.5)
	tween.tween_property($Label, "modulate:a", 1.0, 1.0)
	tween.tween_callback(_play_end_music)

func _play_end_music() -> void:
	var player = AudioStreamPlayer.new()
	player.stream = load("res://sounds/Musics/end_music.wav")
	add_child(player)
	player.play()
