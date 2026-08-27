extends CharacterBody2D

@export var speed: float = 100.0
@export var max_hp: int = 10
@export var damage: int = 3
var hp: int
onready var player: Node2D = null

func _ready():
	hp = max_hp
	# find player in scene
	player = get_tree().get_root().get_node("Main/Player") if has_node("/root/Main/Player") else null

func _physics_process(delta):
	if not player:
		player = get_parent().get_node_or_null("Player")
	if player:
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * speed
		move_and_slide()
		look_at(player.global_position)

func hit(damage_amount: int):
	hp -= damage_amount
	if hp <= 0:
		queue_free()

func _on_body_entered(body):
	if body.name == "Player":
		if body.has_method("take_damage"):
			body.take_damage(damage, global_position)