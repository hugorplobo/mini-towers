extends RigidBody2D

onready var sprite_node = $Sprite
onready var tween_sprite = $SpriteTween
onready var tween_collision = $CollisionTween

export var type = 1
var is_ragdoll = false
var is_rotating = false
var is_moving = false
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
	
	if not is_moving:
		if Input.is_action_pressed("left"):
			move_block(state, 10)
		elif Input.is_action_pressed("right"):
			move_block(state, -10)
	if Input.is_action_pressed("down"):
		state.linear_velocity = Vector2(0, 200)
	if not is_rotating:
		if Input.is_action_just_pressed("rotate_right"):
			rotate_block(90)
		elif Input.is_action_just_pressed("rotate_left"):
			rotate_block(-90)
	if Input.is_action_just_pressed("impulse_right"):
		impulse_block(30)
	elif Input.is_action_just_pressed("impulse_left"):
		impulse_block(-30)

func _on_Block_body_entered(_body):
	if not is_ragdoll:
		is_ragdoll = true
		set_deferred("gravity_scale", 1)
		set_deferred("applied_force", Vector2.ZERO)
		set_deferred("linear_velocity", Vector2.ZERO)
		set_deferred("contact_monitor", false)
		emit_signal("on_touch")

func move_block(state: Physics2DDirectBodyState, amount: int):
	is_moving = true
	state.transform = state.transform.translated(Vector2.LEFT * amount)
	yield(get_tree().create_timer(0.1), "timeout")
	is_moving = false

func rotate_block(angle: int):
	tween_sprite.interpolate_property(
		sprite_node, "rotation_degrees", sprite_node.rotation_degrees, sprite_node.rotation_degrees + angle, 0.25, Tween.TRANS_ELASTIC
	)
	
	tween_collision.interpolate_property(
		collision_node, "rotation_degrees", collision_node.rotation_degrees, collision_node.rotation_degrees + angle, 0.25, Tween.TRANS_ELASTIC
	)
	
	is_rotating = true
	tween_collision.start()
	tween_sprite.start()

func impulse_block(amount: int):
	add_central_force(Vector2.RIGHT * amount * 1000)
	yield(get_tree().create_timer(0.05), "timeout")
	if not is_ragdoll:
		add_central_force(Vector2.LEFT * amount * 1000)

func _on_SpriteTween_tween_all_completed():
	is_rotating = false
