extends Node2D

var field = preload("res://scenes/field/PlayerField.tscn")

func _ready():
	var init_x = 100
	var init_y = 600
	var clients = NetworkServer.ids if NetworkServer.is_server else NetworkClient.clients
	clients.push_front(0)
	
	for client in clients:
		var client_field = field.instance()
		client_field.position = Vector2(init_x, init_y)
		init_x += 300
		add_child(client_field)
