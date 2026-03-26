extends Area2D

@onready var player = get_node("/root/Game/Player")
@onready var timer = $Timer
@onready var shooting_point = $ShootingPoint

var current_target = null
var manual_shooting = false
var shoot_triggered = false

var mouse_recently_moved = false

func _ready():
	adjust_timer_rpm()

func _physics_process(_delta):
	var aim_direction = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if aim_direction.length() > 0.1:
		look_at(global_position + aim_direction)
		mouse_recently_moved = false
	elif mouse_recently_moved:
		var mouse_pos = get_global_mouse_position()
		look_at(mouse_pos)
	else:
		pass

func _input(event):
	if event is InputEventMouseMotion:
		mouse_recently_moved = true

	var trigger_value = Input.get_action_strength("shoot")
	var threshold = 0.5

	if trigger_value > threshold and not shoot_triggered:
		shoot()
		shoot_triggered = true
		if not timer.is_stopped():
			pass
		else:
			timer.start()
	elif trigger_value <= threshold and shoot_triggered:
		shoot_triggered = false
		timer.stop()

func adjust_timer_rpm():
	if global.rpm:
		timer.wait_time = 0.1
	else:
		timer.wait_time = 0.7

func get_closest_enemy(_enemies):
	pass

func shoot():
	var bullet_scene = preload("res://bullet.tscn")
	var bullet = bullet_scene.instantiate()
	bullet.global_position = %ShootingPoint.global_position
	bullet.global_rotation = %ShootingPoint.global_rotation
	get_tree().current_scene.add_child(bullet)

func stop_shooting():
	shoot_triggered = false
	manual_shooting = false
	timer.stop()
