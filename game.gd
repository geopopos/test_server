extends Node2D


var player_character = preload("res://player_character.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Lobby.player_loaded.rpc_id(1)
	var peer_id = multiplayer.get_unique_id()
	$GameUI/VBoxContainer/PeerID.text = str(peer_id)
	$GameUI/VBoxContainer/PlayerInfo.text = str(Lobby.players[peer_id])
	var start_game_button = $GameUI/VBoxContainer/StartGame
	
	if multiplayer.is_server():
		start_game_button.visible = true
	else: 
		var new_player = player_character.instantiate()
		new_player.name = str(multiplayer.get_unique_id())
		add_child(new_player)

	


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func load_player(peer_id):
	var new_player = player_character.instantiate()
	new_player.name = str(peer_id)
	add_child(new_player)

	
func start_game():
	print("game started")


func _on_start_game_pressed():
	start_game()

# deprecated moved this to the GameUI node
#func _on_submit_pressed():
	#var chat = $GameUI/HBoxContainer/Chat
	#var message = chat.text
	#chat.text = ""
	#var player = get_node(str(multiplayer.get_unique_id()))
	#player.set_chat(message)
	#set_chat.rpc(message)

@rpc("any_peer", "reliable")
func set_chat(message):
	var peer_id = multiplayer.get_remote_sender_id()
	var player = get_node(str(peer_id))
	player.set_chat(message)


func _on_game_ui_chat_message_sent(message):
	var player = get_node(str(multiplayer.get_unique_id()))
	player.set_chat(message)
	set_chat.rpc(message)
