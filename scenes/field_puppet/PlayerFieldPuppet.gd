class_name PlayerFieldPuppet
extends Node2D

export var id = -1
var block_scene = preload("res://scenes/block/BlockKinematic.tscn")
var current_block: BlockKinematic = null
var init_block_height: int = 0
var lifes := 3

func _init():
	NetworkClient.connect("state", self, "on_new_state")
	NetworkClient.connect("create_block", self, "handle_new_block")
	NetworkClient.connect("free_block", self, "on_free_block")
	NetworkClient.connect("petrify_all", self, "on_petrify_all")

func _process(delta):
	$CanvasLayer/Vidas.text = "Vidas: %d" % lifes
	
	if current_block == null or id != NetworkClient.id:
		return
	
	if Input.is_action_pressed("left"):
		NetworkClient.send_message("left\n%d" % id)
	elif Input.is_action_pressed("right"):
		NetworkClient.send_message("right\n%d" % id)
	
	if Input.is_action_pressed("down"):
		NetworkClient.send_message("down\n%d" % id)
	
	if Input.is_action_just_pressed("rotate_right"):
		NetworkClient.send_message("rotate right\n%d" % id)
	elif Input.is_action_just_pressed("rotate_left"):
		NetworkClient.send_message("rotate left\n%d" % id)
	
	if Input.is_action_just_pressed("impulse_left"):
		NetworkClient.send_message("impulse left\n%d" % id)
	elif Input.is_action_just_pressed("impulse_right"):
		NetworkClient.send_message("impulse right\n%d" % id)

func handle_new_block(field_id, block_id, block_type, next_block_type):
	if int(field_id) == id:
		new_block(int(block_id), int(block_type), int(next_block_type))

func new_block(block_id: int, block_type: int, next_type: int):
	var block = block_scene.instance()
	block.type = block_type
	block.id = block_id
	block.position = to_local(Vector2(position.x, init_block_height))
	block.update()
	add_child(block)
	current_block = block
	
	var texture = load("res://assets/block%d.png" % next_type)
	$CanvasLayer/NextBlock.texture = texture

func on_new_state(field_id: String, new_state: Array):
	if int(field_id) != id:
		return

	for line in new_state:
		var fields = line.split(" ")
		var block_id = int(fields[0])
		var block_x = float(fields[1])
		var block_y = float(fields[2])
		var block_sr = float(fields[3])
		var block_r = float(fields[4])
		
		for block in get_children():
			if block is BlockKinematic and block.id == block_id:
				block.position = Vector2(block_x, block_y)
				block.set_rotation(block_sr)
				block.rotation_degrees = block_r

func on_free_block(field_id: String, block_id: String):
	if int(field_id) != id:
		return
	
	if lifes >= 1:
		lifes -= 1
	
	for block in get_children():
		if block is BlockKinematic and block.id == int(block_id):
			block.queue_free()

func on_petrify_all(field_id: String):
	if int(field_id) != id:
		return
	
	for block in get_children():
		if block is BlockKinematic:
			block.set_is_petrified(true, true)
