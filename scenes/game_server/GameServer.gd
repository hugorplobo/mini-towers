extends Control

var field = preload("res://scenes/field/PlayerField.tscn")
var block_scene = preload("res://scenes/block/Block.tscn")
var next_id = 0

signal end_game(id)

func _ready():
	var init_x = 100
	var init_y = 600
	var clients = NetworkServer.ids
	clients.push_front(0)
	
	NetworkServer.connect("disconnection", self, "on_disconnection")
	
	for client in clients:
		var client_field: PlayerField = field.instance()
		connect("end_game", client_field, "on_end_game")
		client_field.id = int(client)
		client_field.position = Vector2(init_x, init_y)
		init_x += 300
		add_child(client_field)

func _process(delta):
	if NetworkServer.clients.size() + 1 > 1:
		process_end_game()
	
	var last_pos := Vector2.ZERO
	
	for field in get_children():
		if field is PlayerField:
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
			
			NetworkServer.send_message(build_message(field))

func build_message(parent: Node2D):
	var message = "state\n%d" % parent.id
	for child in parent.get_children():
		if child is Block:
			var block: Block = child
			message += "\n%d %f %f %f %f" % [
				block.id,
				block.position.x,
				block.position.y,
				block.sprite_node.rotation_degrees,
				block.rotation_degrees
			]
	
	return message

func create_block(next_type: int):
	var block = block_scene.instance()
	block.type = next_type
	block.id = next_id
	next_id += 1
	return block

func process_end_game():
	var petrified_count = 0
	var not_petrified: PlayerField
	
	for child in get_children():
		if child is PlayerField and child.lifes < 1:
			petrified_count += 1
		elif child is PlayerField:
			not_petrified = child
	
	if petrified_count == NetworkServer.clients.size():
		NetworkServer.send_message("end game\n%d" % not_petrified.id)
		emit_signal("end_game", not_petrified.id)
		$CanvasLayer/WinnerPanel.visible = true
		$CanvasLayer/WinnerPanel/VBoxContainer/Winner.text = "O Player #%d venceu!" % not_petrified.id

func _on_Goal_body_entered(body):
	if body is Block and body.is_ragdoll:
		NetworkServer.send_message("resize")
		
		for field in get_children():
			if field is PlayerField:
				field.init_block_height -= 300
		
		$Goal.position.y -= 300
		$Tween.interpolate_property($Camera2D, "zoom", $Camera2D.zoom, $Camera2D.zoom + Vector2(0.5, 0.5), 0.5, Tween.TRANS_CUBIC)
		$Tween.interpolate_property($Camera2D, "offset:y", $Camera2D.offset.y, $Camera2D.offset.y - 150, 0.5, Tween.TRANS_CUBIC)
		$Tween.start()

func on_disconnection(player_id: int):
	for child in get_children():
		if child is PlayerField and child.id == player_id:
			print("ENTROU %d" % player_id)
			child.petrify_all()

func _on_Button_button_up():
	NetworkServer.stop_server()
	get_tree().change_scene_to(load("res://scenes/menu/MainScreen.tscn"))
