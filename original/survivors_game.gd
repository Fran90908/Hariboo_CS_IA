extends Node2D

func spawn_mob():
	var new_mob = preload("res://mob.tscn").instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)

func spawn_big_mob():
	var new_big_mob = preload("res://big_mob.tscn").instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_big_mob.global_position = %PathFollow2D.global_position
	add_child(new_big_mob)
	
func spawn_small_mob():
	var new_small_mob = preload("res://small_mob.tscn").instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_small_mob.global_position = %PathFollow2D.global_position
	add_child(new_small_mob)

func _on_timer_timeout():
	spawn_mob()
	
func _on_timer_timeout_big():
	spawn_big_mob()

func _on_timer_timeout_small():
	spawn_small_mob()

func _on_player_health_depleted():
	%GameOver.visible = true
	get_tree().paused = true






