class_name Block
extends RigidBody2D

onready var sprite_node: Sprite = $Sprite
onready var tween_sprite: Tween = $SpriteTween
onready var tween_collision: Tween = $CollisionTween

var gray_shader = preload("res://assets/shaders/Block.gdshader")

export var id := -1
export var type := 1
var is_ragdoll := false
var is_rotating := false
var is_moving := false
var is_petrified := false
var collision_node: CollisionPolygon2D
var commands := []

signal on_touch
signal on_out_screen(id)

func _ready():
	collision_node = get_node("Shape%d" % type)
	$Sprite.texture = load("res://assets/block%d.png" % type)
	$Sprite.material = ShaderMaterial.new()
	$Sprite.material.shader = gray_shader.duplicate()
	collision_node.set_deferred("disabled", false)
	collision_node.visible = true

func _integrate_forces(state):
	if position.y > get_viewport_rect().size.y:
		emit_signal("on_out_screen", id)
	
	if is_ragdoll or is_petrified:
		return
	
	state.linear_velocity = Vector2(0, 100)
	
	for command in commands:
		match command:
			"left":
				move_block(state, 10)
			"right":
				move_block(state, -10)
			"down":
				move_down(state)
			"rotate_left":
				rotate_block(-90)
			"rotate_right":
				rotate_block(90)
			"impulse_left":
				impulse_block(-40)
			"impulse_right":
				impulse_block(40)
	
	commands.clear()

func set_is_petrified(value: bool):
	is_petrified = value
	is_ragdoll = value
	sprite_node.material.set_shader_param("enabled", is_petrified)
	set_deferred("mode", RigidBody2D.MODE_STATIC)

func _on_Block_body_entered(body):
	if body is get_script() and not body.is_ragdoll:
		return
	if not is_ragdoll:
		is_ragdoll = true
		set_deferred("gravity_scale", 1)
		set_deferred("applied_force", Vector2.ZERO)
		set_deferred("linear_velocity", Vector2.ZERO)
		set_deferred("contact_monitor", false)
		emit_signal("on_touch")

func move_block(state: Physics2DDirectBodyState, amount: int):
	if not is_moving:
		is_moving = true
		state.transform = state.transform.translated(Vector2.LEFT * amount)
		yield(get_tree().create_timer(0.1), "timeout")
		is_moving = false

func move_down(state: Physics2DDirectBodyState):
	state.linear_velocity = Vector2(0, 200)

func rotate_block(angle: int):
	if not is_rotating:
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
