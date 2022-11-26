extends Control

var game_server = preload("res://scenes/game_server/GameServer.tscn")
var game = preload("res://scenes/game/Game.tscn")

func _init():
	NetworkServer.connect("connection", self, "on_connection")
	NetworkServer.connect("disconnection", self, "on_disconnection")
	NetworkClient.connect("greetings", self, "on_greetings")
	NetworkClient.connect("start_game", self, "on_start_game")
	NetworkClient.connect("new_player", self, "on_new_player")

func _ready():
	if not NetworkServer.is_server:
		NetworkClient.connect_to_server()
		$Button.visible = false

func on_connection(id: int, ip: String):
	var player_label = Label.new()
	player_label.text = "Player #%d (%s)" %[id, ip]
	$VBoxContainer.add_child(player_label)
	
	if $VBoxContainer.get_child_count() > 0:
		$Button.disabled = false

func on_disconnection(player: String):
	for label in $VBoxContainer.get_children():
		if label.text == player:
			label.free()
	
	if $VBoxContainer.get_child_count() < 1:
		$Button.disabled = true

func on_greetings():
	for id in NetworkClient.clients:
		var label = Label.new()
		label.text = "Player #%s" % id
		$VBoxContainer.add_child(label)

func on_new_player(id):
	var label = Label.new()
	label.align = Label.ALIGN_CENTER
	label.text = "Player #%s" % id
	$VBoxContainer.add_child(label)

func _on_Button_button_up():
	NetworkServer.start_game()
	get_tree().change_scene_to(game_server)

func on_start_game():
	get_tree().change_scene_to(game)
