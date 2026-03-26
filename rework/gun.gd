extends Area2D

@onready var player = get_node("/root/Game/Player")
@onready var timer = $Timer
@onready var shooting_point = %ShootingPoint 
@onready var reload_bar = %reload 

var shoot_triggered = false
var mouse_recently_moved = false

# Variables para controlar la barra sin usar el Timer
var time_since_last_shot = 0.0
var can_shoot_again = true
var cooldown_duration = 0.25 # El tiempo que tarda la barra

func _ready():
	if reload_bar:
		reload_bar.max_value = cooldown_duration
		reload_bar.visible = false

func _physics_process(delta):
	# Lógica de rotación
	var aim_direction = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if aim_direction.length() > 0.1:
		look_at(global_position + aim_direction)
		mouse_recently_moved = false
	elif mouse_recently_moved:
		look_at(get_global_mouse_position())

	# Lógica manual de la barra de recarga
	if not can_shoot_again:
		time_since_last_shot += delta
		reload_bar.value = time_since_last_shot
		reload_bar.visible = true
		
		if time_since_last_shot >= cooldown_duration:
			can_shoot_again = true
			reload_bar.visible = false

func _input(event):
	if not is_visible_in_tree():
		return

	if event is InputEventMouseMotion:
		mouse_recently_moved = true

	var trigger_value = Input.get_action_strength("shoot")
	
	if trigger_value > 0.5:
		# Solo disparamos si nuestra variable manual dice que puede
		if can_shoot_again:
			shoot()
			# Iniciamos el cooldown manual para la barra
			can_shoot_again = false
			time_since_last_shot = 0.0
			
			# Tu Timer sigue haciendo lo que tenga que hacer por su cuenta
			if timer.is_stopped():
				timer.start() 
	else:
		shoot_triggered = false

func shoot():
	if shooting_point == null: return

	var bullet_scene = preload("res://bullet.tscn")
	var bullet = bullet_scene.instantiate()
	
	bullet.global_position = shooting_point.global_position
	bullet.global_rotation = shooting_point.global_rotation
	get_tree().current_scene.add_child(bullet)
