extends CharacterBody2D

@export var speed: float = 180.0
@export var attack_cooldown: float = 0.5
@export var attack_duration: float = 0.15
@export var max_hp: int = 20

var hp: int
var velocity: Vector2 = Vector2.ZERO
var can_attack: bool = true
onready var anim: AnimatedSprite2D = $AnimatedSprite2D
onready var attack_area: Area2D = $AttackArea

func _ready():
	hp = max_hp
	attack_area.connect("area_entered", Callable(self, "_on_attack_area_entered"))
	attack_area.monitoring = false

func _physics_process(delta):
	handle_input()
	move_and_slide()

func handle_input():
	var input_vec = Vector2.ZERO
	input_vec.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vec.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vec = input_vec.normalized()
	velocity = input_vec * speed
	if velocity.length() > 0:
		anim.play("run")
		$AnimatedSprite2D.flip_h = velocity.x < 0
	else:
		anim.play("idle")

func _unhandled_input(event):
	if event.is_action_pressed("attack") and can_attack:
		perform_attack()

func perform_attack():
	can_attack = false
	anim.play("attack")
	attack_area.monitoring = true
	yield(get_tree().create_timer(attack_duration), "timeout")
	attack_area.monitoring = false
	yield(get_tree().create_timer(attack_cooldown - attack_duration), "timeout")
	can_attack = true

func _on_attack_area_entered(area):
	# Expect enemies to have "hit" method
	if area.has_method("hit"):
		area.hit(5)

func take_damage(amount: int, from_pos: Vector2):
	hp -= amount
	if hp <= 0:
		die()
	else:
		# simple knockback
		var dir = (global_position - from_pos).normalized()
		velocity = dir * 200
		anim.play("hit")

func die():
	anim.play("death")
	set_physics_process(false)