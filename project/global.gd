extends Node

var current_phase: int = 1
var player_stats: Stats = null

const PHASES = {
	1: "res://Map/map.tscn",
	2: "res://Map/map2.tscn"
}

func go_to_next_phase() -> void:
	current_phase += 1
	if PHASES.has(current_phase):
		get_tree().change_scene_to_file(PHASES[current_phase])
	else:
		# Acabou todas as fases, fim
		current_phase = 1
		player_stats = null
		get_tree().change_scene_to_file("res://HUD/end.tscn")
