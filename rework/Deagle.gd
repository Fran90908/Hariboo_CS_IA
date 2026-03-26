extends Area2D

@onready var player = get_node("/root/Game/Player")
@onready var timer = $Timer
@onready var shooting_point = %ShootingPoint
@onready var reload_bar = %reload 

var mouse_recently_moved = false
var cooldown_time = 1.5

func _ready():
	timer.wait_time = cooldown_time
	timer.one_shot = true 
	
	reload_bar.max_value = cooldown_time
	reload_bar.value = cooldown_time
	# Empezamos con la barra invisible
	reload_bar.visible = false

func _physics_process(_delta):
	var aim_direction = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if aim_direction.length() > 0.1:
		look_at(global_position + aim_direction)
		mouse_recently_moved = false
	elif mouse_recently_moved:
		look_at(get_global_mouse_position())

func _process(_delta):
	if not timer.is_stopped():
		# Si el timer está corriendo, actualizamos el valor
		reload_bar.value = cooldown_time - timer.time_left
	else:
		# Si el timer se detiene, ocultamos la barra
		if reload_bar.visible:
			reload_bar.visible = false
			reload_bar.value = cooldown_time

func _input(event):
	# SEGURIDAD: Si el arma no es visible (no equipada), ignorar el input
	if not is_visible_in_tree():
		return

	if event is InputEventMouseMotion:
		mouse_recently_moved = true

	if Input.is_action_just_pressed("shoot"):
		if timer.is_stopped(): 
			shoot()
			timer.start()

func shoot():
	var bullet_scene = preload("res://bullet_deagle.tscn")
	var bullet = bullet_scene.instantiate()
	
	bullet.global_position = shooting_point.global_position
	bullet.global_rotation = shooting_point.global_rotation
	get_tree().current_scene.add_child(bullet)

	# Al disparar, reiniciamos la barra y la hacemos visible
	reload_bar.value = 0
	reload_bar.visible = true
