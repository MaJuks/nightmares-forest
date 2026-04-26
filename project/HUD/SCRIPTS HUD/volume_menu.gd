extends CanvasLayer

@onready var slider: HSlider = $HSlider

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Pega o volume atual para inicializar o slider
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = db_to_linear(AudioServer.get_bus_volume_db(0))

func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))

func _on_back_button_pressed() -> void:
	# Reabre o pause menu
	var pause_menu = get_tree().get_first_node_in_group("pause_menu")
	if pause_menu:
		pause_menu.visible = true
	queue_free()
