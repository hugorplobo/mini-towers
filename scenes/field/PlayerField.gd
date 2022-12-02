class_name PlayerField
extends Node2D

var block_scene = preload("res://scenes/block/Block.tscn")
var rng := RandomNumberGenerator.new()
var next_block_int = 0
var lifes := 3
var current_block: Block = null
var init_block_height: int = 0
var has_game_ended := false
onready var next_block: Sprite = $CanvasLayer/NextBlock
export var id = -1

func _init():
	NetworkServer.connect("left", self, "on_move_left")
	NetworkServer.connect("right", self, "on_move_right")
	NetworkServer.connect("down", self, "on_move_down")
	NetworkServer.connect("rotate_left", self, "on_rotate_left")
	NetworkServer.connect("rotate_right", self, "on_rotate_right")
	NetworkServer.connect("impulse_left", self, "on_impulse_left")
	NetworkServer.connect("impulse_right", self, "on_impulse_right")

func _process(delta):
	$CanvasLayer/Vidas.text = "Vidas: %d" % lifes
	
	if id != 0 or current_block == null or has_game_ended:
		return
	
	if Input.is_action_pressed("left"):
		current_block.commands.append("left")
	elif Input.is_action_pressed("right"):
		current_block.commands.append("right")
	
	if Input.is_action_pressed("down"):
		current_block.commands.append("down")
	
	if Input.is_action_just_pressed("rotate_right"):
		current_block.commands.append("rotate_right")
	elif Input.is_action_just_pressed("rotate_left"):
		current_block.commands.append("rotate_left")
	
	if Input.is_action_just_pressed("impulse_left"):
		current_block.commands.append("impulse_left")
	elif Input.is_action_just_pressed("impulse_right"):
		current_block.commands.append("impulse_right")

func _ready():
	yield(get_tree().create_timer(1), "timeout")
	rng.seed = NetworkServer.game_seed
	set_next_block()
	new_block()

func new_block():
	if not has_game_ended:
		var block = get_parent().create_block(next_block_int)
		var type = next_block_int
		block.position = to_local(Vector2(position.x, init_block_height))
		block.connect("on_touch", self, "_on_block_touch")
		block.connect("on_out_screen", self, "_on_block_out")
		add_child(block)
		current_block = block
		set_next_block()
		NetworkServer.send_message("create block\n%d\n%d\n%d\n%d" % [id, block.id, type, next_block_int])

func set_next_block():
	next_block_int = rng.randi_range(1, 7)
	next_block.texture = load("res://assets/block%d.png" % next_block_int)

func _on_block_touch():
	new_block()

func _on_block_out(block_id):
	if has_game_ended:
		return
	
	var block
	for child in get_children():
		if child is Block and child.id == block_id:
			block = child
	
	if lifes < 1:
		petrify_all()
		NetworkServer.send_message("free block\n%d\n%d" % [id, block_id])
		return

	lifes -= 1
	NetworkServer.send_message("free block\n%d\n%d" % [id, block_id])
	
	if not block.is_ragdoll:
		new_block()
	
	block.queue_free()

func petrify_all():
	print("petrificando")
	NetworkServer.send_message("petrify all\n%d" % id)
	for block in get_children():
		if block is Block:
			block.set_is_petrified(true)

func on_move_right(player_id: String):
	if int(player_id) == id and current_block != null:
		current_block.commands.append("right")

func on_move_left(player_id: String):
	if int(player_id) == id and current_block != null:
		current_block.commands.append("left")

func on_move_down(player_id: String):
	if int(player_id) == id and current_block != null:
		current_block.commands.append("down")

func on_rotate_right(player_id: String):
	if int(player_id) == id and current_block != null:
		current_block.commands.append("rotate_right")

func on_rotate_left(player_id: String):
	if int(player_id) == id and current_block != null:
		current_block.commands.append("rotate_left")

func on_impulse_left(player_id: String):
	if int(player_id) == id and current_block != null:
		current_block.commands.append("impulse_left")

func on_impulse_right(player_id: String):
	if int(player_id) == id and current_block != null:
		current_block.commands.append("impulse_right")

func on_end_game(winner_id: int):
	if id != winner_id:
		petrify_all()
	else:
		for block in get_children():
			if block is Block:
				block.set_deferred("mode", RigidBody2D.MODE_STATIC)
