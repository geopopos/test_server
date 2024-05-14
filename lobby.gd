extends Node


signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = 9001
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNECTIONS = 20

var players = {}

var player_info = {"name": "Name"}

var players_loaded = 0


func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.server_disconnected.connect(_on_connected_fail)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	

func join_game(address = ""):
	if address == "":
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

	
func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	
	players[1] = player_info
	player_connected.emit(1, player_info)
	load_game("res://game.tscn")


@rpc("call_local", "reliable")
func load_game(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)

@rpc("reliable")
func load_players(ps):
	players = ps
	for player_id in players:
		$/root/Game.load_player(player_id)
	
# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	var peer_id = multiplayer.get_remote_sender_id()
	$/root/Game.load_player(peer_id)
	if multiplayer.is_server():
		players_loaded += 1
		#if players_loaded == players.size():
			#$/root/Game.start_game()
			#players_loaded = 0

func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null

func _on_player_connected(id):
	print("player connected")
	_register_player.rpc_id(id, player_info)
	if multiplayer.is_server():
		load_players.rpc_id(id, players)
	

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)

func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)


func _on_connected_fail():
	print("failed to connect")
	multiplayer.multiplayer_peer = null


func _on_connected_ok():
	print("connected succesfully")
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)
	load_game("res://game.tscn")

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()




#func _on_create_game_pressed():
	#create_game()
#
#
#func _on_join_game_pressed():
	#join_game()
