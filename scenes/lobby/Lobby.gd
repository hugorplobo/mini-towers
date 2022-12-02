extends Control

var game_server = preload("res://scenes/game_server/GameServer.tscn")
var game = preload("res://scenes/game/Game.tscn")

func _init():
	NetworkServer.connect("connection", self, "on_connection")
	NetworkServer.connect("disconnection", self, "on_disconnection")
	NetworkClient.connect("greetings", self, "on_greetings")
	NetworkClient.connect("start_game", self, "on_start_game")
	NetworkClient.connect("new_player", self, "on_new_player")
	NetworkClient.connect("disconnection", self, "on_disconnection")

func _ready():
	if not NetworkServer.is_server:
		$Button.visible = false
	
	yield(get_tree().create_timer(0.5), "timeout")
	NetworkClient.send_message("get greetings")

func on_connection(id: int, ip: String):
	var player_label = Label.new()
	player_label.align = Label.ALIGN_CENTER
	player_label.text = "Player #%d (%s)" %[id, ip]
	$VBoxContainer.add_child(player_label)
	
	if $VBoxContainer.get_child_count() > 0:
		$Button.disabled = false

func on_disconnection(id: int):
	for label in $VBoxContainer.get_children():
		var text: PoolStringArray = label.text.split(" ")
		print(text)
		if text[1].ends_with("%d" % id):
			label.free()
	
	if $VBoxContainer.get_child_count() < 1:
		$Button.disabled = true

func on_greetings():
	print("greetings received")
	
	for label in $VBoxContainer.get_children():
		if label.name != "Server":
			label.queue_free()
	
	for id in NetworkClient.clients:
		var label = Label.new()
		label.align = Label.ALIGN_CENTER
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
	print("start game received")
	get_tree().change_scene_to(game)
