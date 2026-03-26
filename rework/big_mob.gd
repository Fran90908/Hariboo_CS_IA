extends CharacterBody2D

var health = 5

@onready var player = get_node("/root/Game/Player")
@onready var slime_med = preload("res://mob.tscn")

signal enemy_died

func _ready():
	%Slime.play_walk()

func _physics_process(_delta):
	var distance = global_position.distance_to(player.global_position)
	var direction = global_position.direction_to(player.global_position)
	if distance < 36:
		velocity = direction * 80
	else:
		velocity = direction * 200
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
		global.score += 15
		spawn_med_slime()
		spawn_loot()
		spawn_smoke()
		emit_signal("enemy_died")
		queue_free()

func spawn_med_slime():
	var main_script = get_parent()
	for i in range(3): 
		var mob = slime_med.instantiate() 
		mob.position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
		main_script.call_deferred("add_child", mob)
		if mob.has_signal("enemy_died"):
			mob.call_deferred("connect", "enemy_died", Callable(main_script, "_on_enemy_died"))
		main_script.call_deferred("add_alive_enemy")

func spawn_loot():
	var roll = randf()
	var main_script = get_parent()
	var loot_item = null

	if roll < 0.1:
		pass
	elif roll < 0.2:
		loot_item = preload("res://strength_potion.tscn").instantiate()
	elif roll < 0.3:
		loot_item = preload("res://blue_potion.tscn").instantiate()
	elif roll < 0.4:
		loot_item = preload("res://big_heal_potion.tscn").instantiate()
	else:
		loot_item = preload("res://coins.tscn").instantiate()
	
	if loot_item:
		loot_item.global_position = global_position
		main_script.call_deferred("add_child", loot_item)

func spawn_smoke():
	var smoke = preload("res://smoke_explosion/smoke_explosion.tscn").instantiate()
	smoke.global_position = global_position
	get_parent().call_deferred("add_child", smoke)
