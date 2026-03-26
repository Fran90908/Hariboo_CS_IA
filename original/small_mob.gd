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
	# Prevent further logic if already dead
	if health <= 0:
		return
	# Base damage (increased if strength buff is active)
	var damage = amount
	if global.strength:
		damage *= 3.0
	# Apply damage and play hurt animation
	health -= damage
	%Slime.play_hurt()
	
	if health <= 0:
		# Add score for killing this enemy type
		global.score += 5
		# Notify main game that one enemy died
		emit_signal("enemy_died")
		# Drop loot (coins) based on probability
		spawn_loot()
		# Spawn smoke explosion effect
		spawn_smoke()
		# Removes slime from the scene
		queue_free()

func spawn_loot():
	var main_script = get_parent()
	# 10% chance to drop coins
	if randf() < 0.1:
		var coins = preload("res://coins.tscn").instantiate()
		coins.global_position = global_position
		main_script.call_deferred("add_child", coins)

func spawn_smoke():
	var smoke = preload("res://smoke_explosion/smoke_explosion.tscn").instantiate()
	smoke.global_position = global_position
	# Add smoke effect safely to the scene
	get_parent().call_deferred("add_child", smoke)

