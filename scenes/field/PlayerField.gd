extends Node2D

var block_scene = preload("res://scenes/block/Block.tscn")
var rng = RandomNumberGenerator.new()
var next_block_int = 0
var next_block: TextureRect

export var next_block_path: NodePath

func _ready():
	next_block = get_node(next_block_path)
	set_next_block()
	new_block()

func new_block() -> void:
	var screen_size = get_viewport().size
	var block = block_scene.instance()
	block.type = next_block_int
	block.position = to_local(Vector2(screen_size.x / 2.0, 0))
	block.connect("on_touch", self, "_on_block_touch")
	add_child(block)
	set_next_block()

func set_next_block() -> void:
	rng.randomize()
	next_block_int = rng.randi_range(1, 7)
	next_block.texture = load("res://assets/block%d.png" % next_block_int)

func _on_block_touch():
	new_block()
