extends Node2D

var field = preload("res://scenes/field_puppet/PlayerFieldPuppet.tscn")

func _init():
	NetworkClient.connect("resize", self, "on_camera_resize")

func _ready():
	var init_x = 100
	var init_y = 600
	var clients = NetworkClient.clients
	clients.push_front(0)
	
	for client in clients:
		var client_field = field.instance()
		client_field.get_node("CanvasLayer").offset.x = init_x - 100
		client_field.id = int(client)
		client_field.position = Vector2(init_x, init_y)
		init_x += 300
		add_child(client_field)

func on_camera_resize():
	for field in get_children():
		if field is PlayerFieldPuppet:
			field.init_block_height -= 300
	
	$Goal.position.y -= 300
	$Tween.interpolate_property($Camera2D, "zoom", $Camera2D.zoom, $Camera2D.zoom + Vector2(0.5, 0.5), 0.5, Tween.TRANS_CUBIC)
	$Tween.interpolate_property($Camera2D, "offset:y", $Camera2D.offset.y, $Camera2D.offset.y - 150, 0.5, Tween.TRANS_CUBIC)
	$Tween.start()
