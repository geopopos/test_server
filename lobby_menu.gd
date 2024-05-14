extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_create_game_pressed():
	Lobby.create_game()


func _on_join_game_pressed():
	Lobby.join_game()
