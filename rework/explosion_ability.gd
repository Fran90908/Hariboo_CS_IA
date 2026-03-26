extends Area2D

@onready var collision_shape = $CollisionShape2D
@onready var sprite = $AoE           # Tu imagen AoE.png
@onready var reload_bar = $reload    # Tu ProgressBar

var damage = 999.0                   
var cooldown_time = 20.0             
var can_use = true
var cooldown_timer = 0.0

func _ready():
	# IMPORTANTE: El nodo debe ser visible para que el script procese bien
	self.visible = true 
	
	# El sprite empieza visible solo si ya tenemos la habilidad
	sprite.visible = global.has_explosion
	
	collision_shape.disabled = true
	reload_bar.max_value = cooldown_time
	reload_bar.value = 0
	reload_bar.visible = false
	
	body_entered.connect(_on_body_entered)

func _process(delta):
	# Si no se ha comprado, forzamos que todo esté oculto y salimos
	if not global.has_explosion:
		sprite.visible = false
		reload_bar.visible = false
		return

	# Si se acaba de comprar, el sprite debe aparecer
	if can_use and not sprite.visible:
		sprite.visible = true

	# Lógica de recarga
	if cooldown_timer > 0:
		cooldown_timer -= delta
		reload_bar.value = cooldown_time - cooldown_timer
		
		if cooldown_timer <= 0:
			can_use = true
			reload_bar.visible = false
			sprite.visible = true # Reaparece el indicador cuando carga
			print("¡Boo-m! listo")

	# Entrada "explosion"
	if Input.is_action_just_pressed("explosion") and can_use:
		execute_explosion()

func execute_explosion():
	can_use = false
	cooldown_timer = cooldown_time
	
	# Desaparece el rango y aparece la barra
	sprite.visible = false
	reload_bar.visible = true
	reload_bar.value = 0
	
	# Golpe de daño instantáneo
	collision_shape.disabled = false
	
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.has_method("take_damage"):
			body.take_damage(damage)
	
	# El daño dura solo un instante
	await get_tree().create_timer(0.1).timeout
	collision_shape.disabled = true

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
