extends CharacterBody2D


@export var speed = 300.0

func _ready():
	$PeerID.text = name

func _physics_process(delta):
	var peer_id = multiplayer.get_unique_id()
	if name == str(peer_id):
		var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		
		if input:
			velocity = input * speed

			move_and_slide()
			update_position.rpc(peer_id, position)
		

@rpc("any_peer", "unreliable")
func update_position(peer_id: int, pos: Vector2):
	print("updating " + str(peer_id) + " to position " + str(position))
	position = pos
	
func set_chat(message):
	$ChatLabel.text = message
	$ChatTimeout.start()


func _on_chat_timeout_timeout():
	$ChatLabel.text = ""
