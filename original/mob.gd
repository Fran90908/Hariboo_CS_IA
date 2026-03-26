extends CharacterBody2D

var health = 3

@onready var player = get_node("/root/Game/Player")
@onready var slime_small = preload("res://small_mob.tscn")

signal enemy_died

func _ready():
	%Slime.play_walk()
	add_to_group("slimes")

func _physics_process(_delta):
	var distance = global_position.distance_to(player.global_position)
	var direction = global_position.direction_to(player.global_position)

	if distance < 32:
		velocity = direction * 100
	else:
		velocity = direction * 280

	move_and_slide()

func take_damage(amount := 1.0):
	print("RECIBIDO:", amount)
	if health <= 0:
		return

	var damage = amount
	if global.strength:
		damage *= 3.0  # Triple daño si la poción de fuerza está activa

	health -= damage
	%Slime.play_hurt()

	if health <= 0:
		emit_signal("enemy_died")
		spawn_small_slime()
		spawn_loot()
		spawn_smoke()
		queue_free()
		global.score += 10

func spawn_small_slime():
	for i in range(2):
		# Create small slime instance
		var mob = slime_small.instantiate()
		# Random position offset around the original mob
		mob.position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
		# Add new slime safely to the scene tree
		var main_script = get_parent()
		main_script.call_deferred("add_child", mob)
		# Connect enemy_died signal + update alive enemies count
		if main_script.has_method("_on_enemy_died") and mob.has_signal("enemy_died"):
			mob.call_deferred("connect", "enemy_died", Callable(main_script, "_on_enemy_died"))
			main_script.call_deferred("add_alive_enemy")

func spawn_loot():
	var main_script = get_parent()
	if randf() < 0.1: # 10% chance to drop heal
		var test_tube = preload("res://test_tube.tscn").instantiate()
		test_tube.global_position = global_position
		main_script.call_deferred("add_child", test_tube) 
	elif randf() < 0.5: # 50% chance to drop coins
		var coins = preload("res://coins.tscn").instantiate()
		coins.global_position = global_position
		main_script.call_deferred("add_child", coins)

func spawn_smoke():
	var smoke = preload("res://smoke_explosion/smoke_explosion.tscn").instantiate()
	smoke.global_position = global_position
	get_parent().call_deferred("add_child", smoke)
