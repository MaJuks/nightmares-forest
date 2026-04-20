extends Area2D

@export var cura: int = 20

func _on_item_cura_body_entered(body):
	if body.name == "Player":
		body.receber_cura(cura)
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
