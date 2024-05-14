extends CanvasLayer

signal chat_message_sent

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_submit_pressed():
	var chat_node = $HBoxContainer/Chat
	var message = chat_node.text
	chat_node.text = ""
	
	chat_message_sent.emit(message)
