extends Node2D

var field = preload("res://scenes/field/PlayerField.tscn")
var block_scene = preload("res://scenes/block/Block.tscn")
var next_id = 0

func _ready():
	var init_x = 100
	var init_y = 600
	var clients = NetworkServer.ids
	clients.push_front(0)
	
	for client in clients:
		var client_field = field.instance()
		client_field.id = int(client)
		client_field.position = Vector2(init_x, init_y)
		init_x += 300
		add_child(client_field)

func _process(delta):
	for field in get_children():
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
