extends Node

# Tus variables globales
var heal = false
var speed = false
var strength = false
var rpm = false
var big_heal = false
var score = 0
var wave = 1
var coins = 49
var manual_mode = false
var has_pistol = false
var has_smg = false
var has_m4 = false
var has_dash_ability = false
var tutorial_mode = true
var player_name = ""
var apply_discount = false

# Ruta donde se guardará el archivo de puntuaciones.
const SCORE_FILE_PATH = "user://highscores.json"

# La lista que contendrá los puntajes.
var highscores = []

# Se ejecuta una vez al inicio del juego.
func _ready():
	# Carga los puntajes guardados.
	load_highscores()

func save_player_score():
	# Validate name + score
	if player_name.is_empty() or score == 0:
		return
	var found = false
	# Search for existing entry
	for entry in highscores:
		if entry.player_name == player_name:
			# Update only if the new score is higher
			if score > entry.score:
				entry.score = score
			found = true
			break
	# Add a new entry if player not found
	if not found:
		highscores.append({ "player_name": player_name, "score": score })
	# Sort highscores descending
	highscores.sort_custom(func(a, b): return a.score > b.score)
	# Save to JSON file
	var file = FileAccess.open(SCORE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(highscores))
		file.close()
		
# Función para cargar los puntajes desde el archivo.
func load_highscores():
	if not FileAccess.file_exists(SCORE_FILE_PATH):
		return

	var file = FileAccess.open(SCORE_FILE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	if content.is_empty():
		return
		
	var parsed_data = JSON.parse_string(content)
	if parsed_data and parsed_data is Array:
		highscores = parsed_data

func reset_game_state():
	has_pistol = true
	has_smg = false
	has_m4 = false
	has_dash_ability = false
	speed = false
	strength = false
	rpm = false
	heal = false
	big_heal = false
	score = 0
	wave = 1
	ShopMenu.owned_items = {}
	ShopMenu.equipped_item = ""
	coins = 0
	apply_discount = false
