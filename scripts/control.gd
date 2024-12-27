extends Control

@onready var player_name: LineEdit = $PlayerName

const ADDRESS := "127.0.0.1" 
const PORT := 8910
const MAX_PLAYERS := 2
var peer: ENetMultiplayerPeer


func _ready() -> void:
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)
	multiplayer.connection_failed.connect(on_connection_failed)
	multiplayer.connected_to_server.connect(on_connected_to_server)


func _on_host_button_down() -> void:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_PLAYERS)
	if error != OK:
		print("Failed to create host: " + error)
		return
		
	multiplayer.multiplayer_peer = peer
	send_player_information(player_name.text, multiplayer.get_unique_id())
	print("Waiting for players!")

func _on_join_button_down() -> void:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ADDRESS, PORT)
	if error != OK:
		print("Failed to create client: ", error)
		return
		
	multiplayer.multiplayer_peer = peer

func _on_start_game_button_down() -> void:
	start_game.rpc()
	

# get called on the server and client
func on_peer_connected(id):
	print("Player Connected: " + str(id))

# get called on the server and client
func on_peer_disconnected(id):
	print("Player Disonnected: " + str(id))
	GameManager.players.erase(id)
	var players = get_tree().get_nodes_in_group("Player")
	for i in players:
		if i.name == str(id):
			i.queue_free()
			print(i)

# get called only from client
func on_connection_failed():
	print("Connection failed")
	
# get called only from client
func on_connected_to_server():
	send_player_information.rpc_id(1, player_name.text, multiplayer.get_unique_id())
	print("Connected to Server")
	
	
@rpc("any_peer")
func send_player_information(p_name, id):
	if !GameManager.players.has(id):
		GameManager.players[id] = {
			"name": p_name,
			"id": id,
			"score": 0,
		}
	if multiplayer.is_server():
		for i in GameManager.players:
			send_player_information.rpc(GameManager.players[i].name, i)
			
@rpc("any_peer", "call_local")
func start_game():
	var game_scene = preload("res://scenes/testScene.tscn").instantiate()
	get_tree().root.add_child(game_scene)
	self.hide()
	
