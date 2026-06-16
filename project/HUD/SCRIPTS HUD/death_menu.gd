extends CanvasLayer

func _ready() -> void:
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	$restart_button.process_mode = Node.PROCESS_MODE_ALWAYS
	$exit_button.process_mode = Node.PROCESS_MODE_ALWAYS

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	GameManager.player_stats = null
	GameManager.current_phase = 1
	queue_free()
	get_tree().change_scene_to_file("res://Map/map.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().paused = false
	GameManager.player_stats = null
	GameManager.current_phase = 1
	queue_free()
	get_tree().change_scene_to_file("res://HUD/control.tscn")
