extends CharacterBody2D

var health = 1

@onready var player = get_node("/root/Game/Player")

signal enemy_died

func _ready():
	%Slime.play_walk()

func _physics_process(_delta):
	var distance = global_position.distance_to(player.global_position)
	var direction = global_position.direction_to(player.global_position)

	if distance < 28:
		velocity = direction * 100
	else:
		velocity = direction * 320

	move_and_slide()

func take_damage(amount := 1.0):
	if health <= 0:
		return
	var damage = amount
	if global.strength:
		damage *= 3.0
	health -= damage
	%Slime.play_hurt()

	if health <= 0:
		global.score += 5
		emit_signal("enemy_died")
		spawn_loot()
		spawn_smoke()
		queue_free()

func spawn_loot():
	var main_script = get_parent()
	if randf() < 0.1:
		var coins = preload("res://coins.tscn").instantiate()
		coins.global_position = global_position
		main_script.call_deferred("add_child", coins)

func spawn_smoke():
	var smoke = preload("res://smoke_explosion/smoke_explosion.tscn").instantiate()
	smoke.global_position = global_position
	get_parent().call_deferred("add_child", smoke)
