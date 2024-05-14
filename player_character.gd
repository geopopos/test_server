extends CharacterBody2D


@export var speed = 300.0

var client_input: Vector2

func _ready():
	$PeerID.text = name
	var label_color = "orange"
	if name == str(multiplayer.get_unique_id()):
		label_color = "green"
	$PeerID.add_theme_color_override("font_color", label_color)
	

func _physics_process(delta):
	var peer_id = multiplayer.get_unique_id()
	if name == str(peer_id):
		var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		
		if !multiplayer.is_server():
			if input:
				receive_input.rpc_id(1, input)
			else:
				receive_input.rpc_id(1, Vector2.ZERO)
		else:
			client_input = input
		#if input:
			#velocity = input * speed
#
			#move_and_slide()
			#update_position.rpc(peer_id, position)
	if multiplayer.is_server() and client_input:
		velocity = client_input * speed
		move_and_slide()
		update_position.rpc(int("" + name), position)
		
		

#@rpc("any_peer", "unreliable")
@rpc("unreliable")
func update_position(peer_id: int, pos: Vector2):
	print("updating " + str(peer_id) + " to position " + str(position))
	position = pos
	
	
@rpc("any_peer", "unreliable")
func receive_input(input: Vector2):
	# send input to server
	if multiplayer.is_server():
		client_input = input


func set_chat(message):
	$ChatLabel.text = message
	$ChatTimeout.start()


func _on_chat_timeout_timeout():
	$ChatLabel.text = ""
