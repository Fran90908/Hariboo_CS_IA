extends CharacterBody2D

signal health_depleted

var health = 100.0

var strength_timer_started = false
var speed_timer_started = false
var rpm_timer_started = false

var is_dashing = false
var dash_direction = Vector2.ZERO
var dash_timer = 0.0
var dash_duration = 0.3
var dash_cooldown = 2.0
var dash_cooldown_timer = 0.0

var is_charging_dash = false
var dash_charge_timer = 0.0
var dash_charge_max = 1.2
var overcharge_timer = 0.0
var overcharge_limit = 2.0

var dash_min_speed = 850
var dash_max_speed = 2000

var current_weapon: Node = null

var mouse_hidden = false

func _ready():
	$Gun.visible = false
	$Gun.set_process_input(false)
	$SMG.visible = false
	$SMG.set_process_input(false)
	$M4.visible = false
	$M4.set_process_input(false)

	ShopMenu.item_equipped.connect(Callable(self, "_on_item_equipped"))
	ShopMenu.tutorial_finished.connect(Callable(self, "hide_tutorial_label")) # Make sure this signal is connected

	%DashBar.max_value = dash_cooldown
	%DashBar.visible = false

	%DashCharge.max_value = dash_charge_max
	%DashCharge.visible = false

	%SpeedBar.max_value = $SpeedTimer.wait_time
	%StrengthBar.max_value = $StrengthTimer.wait_time
	%RPMBar.max_value = $RPMTimer.wait_time

	if global.tutorial_mode:
		_on_item_equipped("")
		if has_node("%TutorialMode"): # Check if the node exists before trying to access it
			%TutorialMode.visible = true
	else:
		if ShopMenu.equipped_item != "":
			_on_item_equipped(ShopMenu.equipped_item)
		else:
			_on_item_equipped("Gun") # Default to Gun if no equipped item and not in tutorial
		if has_node("%TutorialMode"):
			%TutorialMode.visible = false

	if global.has_dash_ability:
		print("Player has Dash Ability from start (global state).")

func _physics_process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if is_dashing:
		var charge_ratio = clamp(dash_charge_timer / dash_charge_max, 0.0, 1.0)
		var speed = lerp(dash_min_speed, dash_max_speed, pow(charge_ratio, 1.5))
		velocity = dash_direction * speed
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
			dash_cooldown_timer = dash_cooldown
	elif dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
		velocity = direction * (600 if global.speed else 400)
	else:
		velocity = direction * (600 if global.speed else 400)

	move_and_slide()

	if global.has_dash_ability:
		if is_charging_dash:
			dash_charge_timer = min(dash_charge_timer + delta, dash_charge_max)
			%DashCharge.visible = true
			%DashCharge.value = dash_charge_timer

			var ratio = dash_charge_timer / dash_charge_max
			if ratio < 0.3:
				%DashCharge.modulate = Color("33ff33")
			elif ratio < 0.6:
				%DashCharge.modulate = Color("ffff33")
			elif ratio < 0.9:
				%DashCharge.modulate = Color("ff9933")
			else:
				var pulse = abs(sin(Time.get_ticks_msec() / 100.0))
				%DashCharge.modulate = Color(1, pulse * 0.3 + 0.3, pulse * 0.3 + 0.3)
				overcharge_timer += delta
				if overcharge_timer > overcharge_limit:
					is_charging_dash = false
					dash_charge_timer = 0.0
					overcharge_timer = 0.0
					%DashCharge.visible = false
					%DashCharge.value = 0
					%DashCharge.modulate = Color.WHITE
		else:
			%DashCharge.visible = false
			%DashCharge.value = 0
			overcharge_timer = 0.0
	else:
		%DashCharge.visible = false
		%DashCharge.value = 0
		is_charging_dash = false

	%DashBar.visible = global.has_dash_ability and (is_dashing or dash_cooldown_timer > 0.0)
	%DashBar.value = dash_cooldown - dash_cooldown_timer

	if global.heal:
		health = min(health + 25, 100)
		global.heal = false

	if global.big_heal:
		health = min(health + 50, 100)
		global.big_heal = false

	%ProgressBar.value = health

	if global.speed and not speed_timer_started:
		$SpeedTimer.start()
		speed_timer_started = true
		%SpeedBar.visible = true
	if global.strength and not strength_timer_started:
		$StrengthTimer.start()
		strength_timer_started = true
		%StrengthBar.visible = true

	if global.rpm and not rpm_timer_started:
		$RPMTimer.start()
		rpm_timer_started = true
		%RPMBar.visible = true

	%SpeedBar.value = $SpeedTimer.time_left
	%StrengthBar.value = $StrengthTimer.time_left
	%RPMBar.value = $RPMTimer.time_left

	%SpeedBar.visible = $SpeedTimer.time_left > 0
	%StrengthBar.visible = $StrengthTimer.time_left > 0
	%RPMBar.visible = $RPMTimer.time_left > 0

	if velocity.length() > 0.0:
		$HappyBoo.play_walk_animation()
	else:
		$HappyBoo.play_idle_animation()

	var damage = 0.0
	damage += %HurtBox.get_overlapping_bodies().size() * 75.0
	damage += %HurtBoxBig.get_overlapping_bodies().size() * 200.0
	damage += %HurtBoxSmall.get_overlapping_bodies().size() * 5.0
	health -= damage * delta
	%ProgressBar.value = health
	if health <= 0.0:
		health_depleted.emit()

func hide_tutorial_label():
	if has_node("%TutorialMode"):
		%TutorialMode.visible = false

func _input(event):
	if event is InputEventMouseMotion:
		if mouse_hidden:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mouse_hidden = false

	var aim_dir = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if aim_dir.length() > 0.1:
		if not mouse_hidden:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			mouse_hidden = true

	if global.has_dash_ability:
		if event.is_action_pressed("dash") and dash_cooldown_timer <= 0.0 and not is_dashing:
			is_charging_dash = true
			dash_charge_timer = 0.0
			overcharge_timer = 0.0

		if event.is_action_released("dash") and is_charging_dash:
			var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
			if input_dir != Vector2.ZERO:
				is_dashing = true
				dash_direction = input_dir.normalized()
				var charge_ratio = clamp(dash_charge_timer / dash_charge_max, 0.0, 1.0)
				dash_timer = lerp(dash_duration, dash_duration * 1.7, charge_ratio)
				print("DASH con carga: ", dash_charge_timer)
			is_charging_dash = false
			dash_charge_timer = 0.0
			overcharge_timer = 0.0

func switch_weapon(name: String):
	if current_weapon:
		if "stop_shooting" in current_weapon:
			current_weapon.stop_shooting()
		current_weapon.visible = false
		current_weapon.set_process_input(false)

	if name == "Dash Ability":
		return

	current_weapon = get_node(name)
	if current_weapon:
		current_weapon.visible = true
		current_weapon.set_process_input(true)
		print("Arma activa: ", name)
	else:
		print("Error: No se encontró el nodo del arma: ", name)

func _on_item_equipped(item_name: String):
	if item_name == "Dash Ability":
		global.has_dash_ability = true
		print("Player now has Dash Ability ready. (From signal)")
		return

	switch_weapon(item_name)

func _on_strength_timer_timeout():
	%StrengthBar.visible = false
	global.strength = false
	strength_timer_started = false
	print("no more strength")

func _on_speed_timer_timeout():
	%SpeedBar.visible = false
	global.speed = false
	speed_timer_started = false
	print("no more speed")

func _on_rpm_timer_timeout():
	%RPMBar.visible = false
	global.rpm = false
	rpm_timer_started = false
	print("no more rpm")
