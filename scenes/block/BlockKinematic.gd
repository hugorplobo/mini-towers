class_name BlockKinematic
extends KinematicBody2D

onready var sprite_node = $Sprite

var gray_shader = preload("res://assets/shaders/Block.gdshader")

export var id := -1
export var type := 1
var is_petrified := false
var collision_node: CollisionPolygon2D

func _ready():
	collision_node = get_node("Shape%d" % type)
	$Sprite.texture = load("res://assets/block%d.png" % type)
	$Sprite.material = ShaderMaterial.new()
	$Sprite.material.shader = gray_shader.duplicate()
	collision_node.set_deferred("disabled", false)
	collision_node.visible = true

func _process(delta):
	if position.y > get_viewport_rect().size.y:
		queue_free()

func set_is_petrified(value: bool):
	is_petrified = value
	sprite_node.material.set_shader_param("enabled", is_petrified)

func update():
	collision_node.set_deferred("disabled", true)
	collision_node.visible = false
	
	collision_node = get_node("Shape%d" % type)
	$Sprite.texture = load("res://assets/block%d.png" % type)
	collision_node.set_deferred("disabled", false)
	collision_node.visible = true

func set_rotation(rotation: float):
	$Sprite.rotation_degrees = rotation
	collision_node.rotation_degrees = rotation
