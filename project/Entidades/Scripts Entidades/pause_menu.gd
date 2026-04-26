extends CanvasLayer

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("pause_menu")
	
	$continue_button.process_mode = Node.PROCESS_MODE_ALWAYS
	$volume_button.process_mode = Node.PROCESS_MODE_ALWAYS
	$exit_button.process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause() -> void:
	get_tree().paused = !get_tree().paused
	visible = get_tree().paused

# Botão Continuar
func _on_continue_button_pressed() -> void:
	toggle_pause()

# Botão Volume
func _on_volume_button_pressed() -> void:
	visible = false
	var volume_menu = preload("res://HUD/volume_menu.tscn").instantiate()
	volume_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(volume_menu)

# Botão Sair
func _on_exit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://HUD/control.tscn")
