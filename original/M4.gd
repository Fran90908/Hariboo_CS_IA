extends Area2D

@onready var player = get_node("/root/Game/Player")
@onready var timer = $Timer
@onready var shooting_point = $ShootingPoint

var current_target = null
var manual_shooting = false
var mouse_recently_moved = false
var accumulated_hold_time = 0.0

const MIN_SPREAD = 1.5
const MAX_SPREAD = 10.0
const HOLD_MAX = 4.0
const CADENCE = 0.12

func _ready():
	timer.wait_time = CADENCE
	timer.autostart = false
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)

func _physics_process(delta):
	var aim_direction = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if aim_direction.length() > 0.1:
		look_at(global_position + aim_direction)
		mouse_recently_moved = false
	elif mouse_recently_moved:
		var mouse_pos = get_global_mouse_position()
		look_at(mouse_pos)
	else:
		pass

	if manual_shooting:
		accumulated_hold_time = min(accumulated_hold_time + delta, HOLD_MAX)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_recently_moved = true

	var trigger_value = Input.get_action_strength("shoot")
	var threshold = 0.5

	if trigger_value > threshold and not manual_shooting:
		manual_shooting = true
		accumulated_hold_time = 0.0
		shoot()
		timer.start()
	elif trigger_value <= threshold and manual_shooting:
		manual_shooting = false
		timer.stop()
		accumulated_hold_time = 0.0

func _on_timer_timeout():
	if manual_shooting:
		shoot()

func shoot():
	var bullet_scene = preload("res://bullet_m4.tscn")
	var bullet = bullet_scene.instantiate()
	bullet.global_position = %ShootingPoint.global_position
	
	var ratio = accumulated_hold_time / HOLD_MAX
	var spread_deg = lerp(MIN_SPREAD, MAX_SPREAD, clamp(ratio, 0.0, 1.0))
	var signM4 = -1 if randf() < 0.5 else 1
	var spread_rad = deg_to_rad(spread_deg) * signM4
	
	bullet.global_rotation = %ShootingPoint.global_rotation + spread_rad

	get_tree().current_scene.add_child(bullet)

func stop_shooting():
	manual_shooting = false
	timer.stop()
	accumulated_hold_time = 0.0
