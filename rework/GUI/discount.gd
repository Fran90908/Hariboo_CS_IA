extends CanvasLayer

# Variable para almacenar la respuesta correcta
var current_correct_answer = 0

func _ready():
	# 1. Oculta el menú al instanciarse
	visible = false
	
	# 2. Configura y muestra la primera pregunta
	setup_new_question()

func setup_new_question():
	var math_problem = generate_random_question()
	
	# Muestra la pregunta en el Label con el nombre único %Equation
	%equation.text = math_problem.question
	
	# Guarda la respuesta correcta
	current_correct_answer = math_problem.answer
	
	print("Pregunta generada: ", math_problem.question, " | Respuesta: ", current_correct_answer)

func generate_random_question():
	var x = randi_range(1, 100)
	var y = randi_range(1, 100)
	
	var operation_index = randi_range(0, 2) 
	var z = ""
	var correct_answer = 0
	
	match operation_index:
		0:
			z = "+"
			correct_answer = x + y
		1:
			z = "-"
			# Asegurar que el primer número es mayor o igual para la resta
			if x < y: 
				var temp = x
				x = y
				y = temp
			correct_answer = x - y
		2:
			z = "*"
			# Limitar el rango del multiplicador para que el resultado no sea excesivamente grande
			if y > 12: 
				y = randi_range(1, 12) 
			correct_answer = x * y
	
	var question_string = str(x) + " " + z + " " + str(y) + " ="
	
	return {
		"question": question_string,
		"answer": correct_answer
	}



func _on_submit_pressed():
	# 1. Obtener el texto del campo de respuesta... (misma lógica)
	var user_input = %Insert_answer.text
	var user_answer = 0
	
	if user_input.is_valid_int():
		user_answer = user_input.to_int()
	else:
		print("INCORRECT: Introduce un número válido.")
		
		# Ocultamos el Descuento y regresamos a la Tienda
		visible = false
		ShopMenu.visible = true # ⬅️ Regresa a la Tienda
		get_tree().paused = true # Mantiene la pausa, ya que la Tienda la gestiona
		return 
		
	# 2. Comprobar la respuesta
	if user_answer == current_correct_answer:
		global.apply_discount = true
		print("CORRECT! Descuento Aplicado.")
		
		# Opcional: Limpiar el campo
		%Insert_answer.text = "" 
	else:
		print("INCORRECT")
		
		# Opcional: Limpiar el campo
		%Insert_answer.text = ""
	
	# 3. Finalizar: Ocultar Descuento y MOSTRAR LA TIENDA
	visible = false
	ShopMenu.set_initial_shop_state()
	ShopMenu.visible = true 
	get_tree().paused = true
