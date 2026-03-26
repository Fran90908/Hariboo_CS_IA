extends Control

	
func _on_start_game_pressed():
	get_tree().change_scene_to_file("res://nameinput.tscn")
	global.tutorial_mode = true



func _on_exit_pressed():
	get_tree().quit()


func _on_leaderboard_pressed():
	get_tree().change_scene_to_file("res://leader_board.tscn")
