extends CanvasLayer

func _ready() -> void:
	$Label.modulate.a = 0
	$ColorRect.modulate.a = 0

	var tween = create_tween()
	tween.tween_property($ColorRect, "modulate:a", 1.0, 2.0)
	tween.tween_interval(0.5)
	tween.tween_property($Label, "modulate:a", 1.0, 1.0)
