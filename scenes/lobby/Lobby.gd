extends Control

func _ready():
	NetworkServer.connect("connection", self, "on_connection")
	NetworkServer.connect("disconnection", self, "on_disconnection")

func on_connection(player: String):
	var player_label = Label.new()
	player_label.text = player
	$VBoxContainer.add_child(player_label)
