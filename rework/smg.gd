extends Area2D

@onready var player = get_node("/root/Game/Player") # Asegúrate de que esta ruta sigue siendo correcta
@onready var timer = $Timer
@onready var shooting_point = $ShootingPointSMG

var current_target = null # Esta variable ya no será necesaria, pero la dejo por si la usas en otro lado
var manual_shooting = false
var mouse_recently_moved = false
var accumulated_hold_time = 0.0

const MIN_SPREAD = 2.0
const MAX_SPREAD = 8.0
const HOLD_MAX = 5.0

func _ready():
	timer.wait_time = 0.2
	timer.autostart = false
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)

func _physics_process(delta):
	# *** Lógica de Apuntado Manual (únicamente) ***
	# Siempre mira hacia la posición del ratón o la dirección del stick
	var aim_direction = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if aim_direction.length() > 0.1:
		# Si se está usando el stick de apuntado, mira en esa dirección
		look_at(global_position + aim_direction)
		mouse_recently_moved = false # Reinicia esto si usas el stick
	elif mouse_recently_moved:
		# Si el ratón se ha movido recientemente, mira hacia el ratón
		var mouse_pos = get_global_mouse_position()
		look_at(mouse_pos)
	else:
		# Si no hay entrada de apuntado activa (ni stick ni ratón),
		# la dirección del arma se mantiene como estaba.
		pass # No hacemos nada aquí, la última posición de apuntado se mantiene.


	# Si estás disparando, acumula tiempo para la dispersión
	if manual_shooting:
		accumulated_hold_time = min(accumulated_hold_time + delta, HOLD_MAX)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_recently_moved = true

	var trigger_value = Input.get_action_strength("shoot")
	var threshold = 0.5 # Umbral para detectar si el botón de disparo está presionado

	# Lógica para iniciar o detener el disparo manual
	if trigger_value > threshold and not manual_shooting:
		manual_shooting = true
		accumulated_hold_time = 0.0
		shoot() # Dispara la primera bala inmediatamente
		timer.start() # Inicia el temporizador para disparos continuos
	elif trigger_value <= threshold and manual_shooting:
		manual_shooting = false
		timer.stop()
		accumulated_hold_time = 0.0

func _on_timer_timeout():
	if manual_shooting: # Asegúrate de que el disparo continuo solo ocurre si manual_shooting es true
		shoot()

func shoot():
	var bullet_scene = preload("res://bullet_smg.tscn") # Asegúrate de que la bala sea la correcta
	var bullet = bullet_scene.instantiate()
	bullet.global_position = %ShootingPointSMG.global_position
	
	# Dispersión progresiva según el tiempo de disparo continuo
	var ratio = accumulated_hold_time / HOLD_MAX
	var spread_deg = lerp(MIN_SPREAD, MAX_SPREAD, clamp(ratio, 0.0, 1.0))
	var signSMG = -1 if randf() < 0.5 else 1
	var spread_rad = deg_to_rad(spread_deg) * signSMG
	
	bullet.global_rotation = %ShootingPointSMG.global_rotation + spread_rad

	get_tree().current_scene.add_child(bullet)

func stop_shooting():
	manual_shooting = false
	timer.stop()
	accumulated_hold_time = 0.0
