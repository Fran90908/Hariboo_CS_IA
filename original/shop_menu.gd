extends CanvasLayer

signal item_equipped(item_name)
signal tutorial_finished

@onready var detail_panel_item_name = %ItemName
@onready var detail_panel_item_description = %ItemDescription
@onready var detail_panel_price_label = %PriceLabel
@onready var detail_panel_texture_rect = %TextureRect
@onready var detail_panel_buy_button = %BuyButton
@onready var detail_panel_owned_label = %OwnedLabel
@onready var detail_panel_equip_button = %EquipButton
@onready var animation_player = %AnimationPlayer
@onready var discount_applied_label = %discount_applied
@onready var discount_button = %DiscountButton

var owned_items = {}      # Items owned by the player
var equipped_item = ""    # Currently equipped item
var current_item = ""     # Item currently selected in the UI

func _ready():
	visible = false
	set_initial_shop_state()

	owned_items["Gun"] = global.has_pistol
	owned_items["SMG"] = global.has_smg
	owned_items["M4"] = global.has_m4
	owned_items["Dash Ability"] = global.has_dash_ability

func _on_close_button_pressed():
	get_tree().paused = false
	visible = false
	set_initial_shop_state()

func set_initial_shop_state():
	detail_panel_item_name.text = ""
	detail_panel_item_description.text = "Click an item to view its details!"
	detail_panel_price_label.text = "Price: ---"
	detail_panel_texture_rect.texture = null
	detail_panel_buy_button.visible = false
	detail_panel_owned_label.visible = false
	detail_panel_equip_button.visible = false
	current_item = ""

	if global.apply_discount:
		discount_applied_label.visible = true
		discount_button.visible = false
	else:
		discount_applied_label.visible = false
		discount_button.visible = true

func update_detail(name: String, description: String, price_text: String, texture: Texture):
	detail_panel_item_name.text = name
	detail_panel_item_description.text = description
	detail_panel_texture_rect.texture = texture
	current_item = name

	var owned = owned_items.get(name, false)
	var item_data = get_item_info_by_name(name)
	var final_price_text = price_text
	var item_price = item_data.price

	if global.apply_discount and item_price > 0:
		var discount_amount = item_price * 0.15
		var discounted_price = item_price - discount_amount
		
		var final_price = int(round(discounted_price)) 
		
		final_price_text = str(final_price) + " (WAS " + str(item_price) + ")"
	
	detail_panel_price_label.text = "Price: " + final_price_text
	detail_panel_buy_button.visible = not owned
	detail_panel_owned_label.visible = owned

	if name == "Dash Ability":
		detail_panel_equip_button.visible = false
	elif owned:
		detail_panel_equip_button.visible = (name != equipped_item)
	else:
		detail_panel_equip_button.visible = false

func _on_shop_item_pistol_button_pressed():
	update_detail(
		"Gun",
		"Your trusty little pew-pew. Not fancy, but it gets the job done.",
		"Free",
		preload("res://Weapons/pistolita.png")
	)

func _on_shop_item_smg_button_pressed():
	update_detail(
		"SMG",
		"Spray and pray! Unleash a storm of bullets up close.",
		"15",
		preload("res://Weapons/Subfusil.png")
	)

func _on_shop_item_m_4_button_pressed():
	update_detail(
		"M4",
		"So shiny even the slimes will run screaming.",
		"30",
		preload("res://Weapons/M4.png")
	)

func _on_shop_item_dash_button_pressed():
	update_detail(
		"Dash Ability",
		"Whoosh! Escape trouble or zip into action.",
		"5",
		preload("res://Weapons/Dash_ability.png")
	)

func _on_buy_button_pressed():
	var item_data = get_item_info_by_name(current_item)
	if not item_data:
		print("Error: No se encontró la información del artículo.")
		return

	var item_price = item_data.price
	var final_price = item_price
	
	if global.apply_discount and item_price > 0:
		var discount_amount = item_price * 0.15
		final_price = int(round(item_price - discount_amount))

	if global.coins >= final_price:
		if final_price > 0:
			global.coins -= final_price
			print("Comprado " + current_item + ". Monedas restantes: " + str(global.coins))

		owned_items[current_item] = true

		if current_item == "Gun":
			global.has_pistol = true
			if global.tutorial_mode:
				global.tutorial_mode = false
				tutorial_finished.emit()
				var main_script_node = get_tree().get_root().find_child("MainScript", true, false)
				if main_script_node:
					main_script_node.start_game_after_tutorial()
				else:
					print("Error: No se pudo encontrar el nodo 'MainScript'.")
		elif current_item == "SMG":
			global.has_smg = true
		elif current_item == "M4":
			global.has_m4 = true
		elif current_item == "Dash Ability":
			global.has_dash_ability = true

		update_detail(item_data.name, item_data.description, item_data.price_text, item_data.texture)
		_on_equip_button_pressed()

	else:
		print("¡No tienes suficientes monedas para comprar " + current_item + "!")
		if animation_player:
			animation_player.play("not_enough_muneh")
		else:
			print("Error: AnimationPlayer no encontrado o no asignado.")


func _on_equip_button_pressed():
	equipped_item = current_item
	item_equipped.emit(equipped_item)
	var item_data = get_item_info_by_name(current_item)
	if item_data:
		update_detail(item_data.name, item_data.description, item_data.price_text, item_data.texture)

func get_item_info_by_name(name: String):
	match name:
		"Gun":
			return {
				"name": "Gun",
				"description": "Your trusty little pew-pew. Not fancy, but it gets the job done.",
				"price": 0,
				"price_text": "Free",
				"texture": preload("res://Weapons/pistolita.png")
			}
		"SMG":
			return {
				"name": "SMG",
				"description": "Spray and pray! Unleash a storm of bullets up close.",
				"price": 15,
				"price_text": "15",
				"texture": preload("res://Weapons/Subfusil.png")
			}
		"M4":
			return {
				"name": "M4",
				"description": "So shiny even the slimes will run screaming.",
				"price": 30,
				"price_text": "30",
				"texture": preload("res://Weapons/M4.png")
			}
		"Dash Ability":
			return {
				"name": "Dash Ability",
				"description": "Whoosh! Escape trouble or zip into action.",
				"price": 5,
				"price_text": "5",
				"texture": preload("res://Weapons/Dash_ability.png")
			}
		_:
			return null

func _on_discount_button_pressed():
	# 1. Ocultar la Tienda actual (este script, que es el Autoload)
	visible = false 
	
	# 2. Mostrar el Autoload del Descuento
	# ESTO FUNCIONARÁ si 'Discount' es el nombre exacto de tu Singleton.
	Discount.visible = true
