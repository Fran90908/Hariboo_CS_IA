extends Area2D

var damage = 2
var travelled_distance := 0

func _physics_process(delta):
	const SPEED := 1200
	const RANGE := 1200
	position += Vector2.RIGHT.rotated(rotation) * SPEED * delta
	travelled_distance += SPEED * delta
	if travelled_distance > RANGE:
		queue_free()

func _on_body_entered(body):
	print("La bala va a hacer daño:", damage)
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
