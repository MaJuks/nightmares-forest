extends Area2D

@export var cura: int = 20


func _on_body_entered(body: Node2D) -> void:
	print("Colidiu com:", body.name)
	
	if body.has_method("receber_cura"):
		body.receber_cura(cura)
		queue_free()
