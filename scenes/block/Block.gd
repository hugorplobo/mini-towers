extends RigidBody2D

onready var sprite_node = $Sprite
onready var tween_sprite = $SpriteTween
onready var tween_collision = $CollisionTween

export var type = 1
var is_ragdoll = false
var is_rotating = false
var target_angle = 0
var collision_node: CollisionPolygon2D

signal on_touch

func _ready():
	collision_node = get_node("Shape%d" % type)
	$Sprite.texture = load("res://assets/block%d.png" % type)
	collision_node.set_deferred("disabled", false)
	collision_node.visible = true

func _integrate_forces(state):
	if is_ragdoll:
		return
	
	state.linear_velocity = Vector2(0, 100)
	
	if Input.is_action_pressed("left"):
		state.transform = state.transform.translated(Vector2.LEFT)
	elif Input.is_action_pressed("right"):
		state.transform = state.transform.translated(Vector2.RIGHT)
	elif Input.is_action_pressed("down"):
		state.linear_velocity = Vector2(0, 200)
	
	if Input.is_action_just_pressed("rotate_right"):
		rotate_right()

func _on_Block_body_entered(_body):
	if not is_ragdoll:
		is_ragdoll = true
		set_deferred("gravity_scale", 1)
		set_deferred("contact_monitor", false)
		emit_signal("on_touch")

func rotate_right():
	tween_sprite.interpolate_property(
		sprite_node, "rotation_degrees", sprite_node.rotation_degrees, sprite_node.rotation_degrees + 90, 0.5, Tween.TRANS_ELASTIC
	)
	
	tween_collision.interpolate_property(
		collision_node, "rotation_degrees", collision_node.rotation_degrees, collision_node.rotation_degrees + 90, 0.5, Tween.TRANS_ELASTIC
	)
	
	tween_collision.start()
	tween_sprite.start()
