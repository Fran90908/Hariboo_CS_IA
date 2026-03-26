extends Control

@onready var name_input = $Insert_name_box

func _on_button_pressed():
	# Obtiene el texto y elimina espacios en blanco al inicio/final
	var player_name = name_input.text.strip_edges()

	# Comprueba si el nombre no está vacío
	if not player_name.is_empty():
		# Asigna el nombre a la variable global
		global.player_name = player_name
		
		# Cambia a la escena del juego
		get_tree().change_scene_to_file("res://survivors_game.tscn")
	else:
		# Puedes añadir un mensaje para el jugador
		print("¡El nombre no puede estar vacío!")
		%AnimationPlayer.play("no_name")
