extends Area2D

# Aumentamos el daño significativamente para la Deagle
var damage = 5
var travelled_distance := 0

func _physics_process(delta):
	# Una Deagle suele tener balas más rápidas
	const SPEED := 1500 
	const RANGE := 1500
	
	position += Vector2.RIGHT.rotated(rotation) * SPEED * delta
	travelled_distance += SPEED * delta
	
	if travelled_distance > RANGE:
		queue_free()

func _on_body_entered(body):
	# Log para debug
	print("Deagle shot hit! Damage: ", damage)
	
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	# La bala desaparece al chocar
	queue_free()
