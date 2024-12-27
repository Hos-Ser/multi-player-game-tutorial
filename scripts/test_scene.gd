extends Node2D

@export var player_scene : PackedScene

func _ready() -> void:
	var index := 1
	var current_player
	for i in GameManager.players:
		current_player = player_scene.instantiate()
		current_player.name = str(GameManager.players[i].id)
		add_child(current_player)
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPosition"):
			if spawn.name == str(index):
				current_player.global_position = spawn.global_position
		index += 1
