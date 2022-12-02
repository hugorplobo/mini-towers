extends Control

var field = preload("res://scenes/field_puppet/PlayerFieldPuppet.tscn")

func _init():
	NetworkClient.connect("end_game", self, "on_end_game")
	NetworkClient.connect("resize", self, "on_camera_resize")

func _ready():
	var init_x = 100
	var init_y = 600
	var clients = NetworkClient.clients
	clients.push_front(0)
	
	for client in clients:
		var client_field = field.instance()
		client_field.id = int(client)
		client_field.position = Vector2(init_x, init_y)
		init_x += 300
		add_child(client_field)

func _process(delta):
	var last_pos := Vector2.ZERO
	
	for field in get_children():
		if field is PlayerFieldPuppet:
			var canvas: CanvasLayer = field.get_node("CanvasLayer")
			var label: Label = canvas.get_node("Label")
			var next_block: Sprite = canvas.get_node("NextBlock")
			var zoom = 0 if $Camera2D.zoom.x == 1 else $Camera2D.zoom.x
			
			if last_pos != Vector2.ZERO:
				label.rect_position = Vector2(last_pos.x + 250 - zoom * 20, last_pos.y)
				next_block.position = Vector2(label.rect_position.x + 40, label.rect_position.y + 60)
			else:
				label.rect_position = Vector2(field.position.x - 80 + 80 * zoom, 10)
				next_block.position = Vector2(label.rect_position.x + 40, label.rect_position.y + 60)
			
			canvas.get_node("Vidas").rect_position = Vector2(label.rect_position.x, label.rect_position.y + 17)
			
			last_pos = label.rect_position

func on_camera_resize():
	for field in get_children():
		if field is PlayerFieldPuppet:
			field.init_block_height -= 300
	
	$Goal.position.y -= 300
	$Tween.interpolate_property($Camera2D, "zoom", $Camera2D.zoom, $Camera2D.zoom + Vector2(0.5, 0.5), 0.5, Tween.TRANS_CUBIC)
	$Tween.interpolate_property($Camera2D, "offset:y", $Camera2D.offset.y, $Camera2D.offset.y - 150, 0.5, Tween.TRANS_CUBIC)
	$Tween.start()

func on_end_game(player_id):
	$CanvasLayer/WinnerPanel.visible = true

func _on_Button_button_up():
	NetworkClient.disconnect_from_server()
	get_tree().change_scene_to(load("res://scenes/menu/MainScreen.tscn"))
