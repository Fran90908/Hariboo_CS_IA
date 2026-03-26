extends CanvasLayer

@onready var container: VBoxContainer = %LeaderboardContainer
@export var button_scene: PackedScene = preload("res://Leaderboard/leaderboard_button.tscn")

func _ready() -> void:
	global.load_highscores()
	_populate(global.highscores)

func _populate(data: Array) -> void:
	data.sort_custom(func(a, b): return int(b.get("score", 0)) < int(a.get("score", 0)))

	# Limpia los botones viejos
	for child in container.get_children():
		child.queue_free()

	# Instancia un botón por cada entrada
	for entry in data:
		var row: Button = button_scene.instantiate() as Button
		container.add_child(row)
		_set_row(row, entry)

func _set_row(row: Button, entry: Dictionary) -> void:
	var name := str(entry.get("player_name", "—"))
	var score := str(entry.get("score", 0))

	(row.get_node("Label") as Label).text = name
	(row.get_node("ScoreLabel") as Label).text = score


func _on_button_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")
