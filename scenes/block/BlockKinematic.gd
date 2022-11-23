class_name BlockKinematic
extends KinematicBody2D

onready var sprite_node = $Sprite

export var id := -1
export var type = 1
var collision_node: CollisionPolygon2D

func _ready():
	collision_node = get_node("Shape%d" % type)
	$Sprite.texture = load("res://assets/block%d.png" % type)
	collision_node.set_deferred("disabled", false)
	collision_node.visible = true

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
