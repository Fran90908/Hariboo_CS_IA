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
	#Generate 2 random numbers between 100 and 1000
	var x = randi_range(100, 1000)
	var y = randi_range(100, 1000)
	
	var operation_index = randi_range(0, 2)
	var z = ""
	var correct_answer = 0
	
	match operation_index:
		0:
			z = "+"
			correct_answer = x + y
		1:
			z = "-"
			#Avoid negative results
			if x < y: 
				var temp = x
				x = y
				y = temp
			correct_answer = x - y
		2:
			z = "*"
			#Make multiplication questions easier
			if x > 100 and y > 100:
				x = randi_range(10, 100)
				y = randi_range(10, 100)
			correct_answer = x * y
	
	var question_string = str(x) + " " + z + " " + str(y) + " ="
	
	return {
		"question": question_string,
		"answer": correct_answer
	}



func _on_submit_pressed():
	var user_input = %Insert_answer.text
	var user_answer = 0
	
	if user_input.is_valid_int():
		user_answer = user_input.to_int()
	else:
		visible = false
		ShopMenu.visible = true
		get_tree().paused = true
		return 
		
	if user_answer == current_correct_answer:
		global.apply_discount = true
		%Insert_answer.text = "" 
		
	else:
		%Insert_answer.text = ""
		
	visible = false
	ShopMenu.set_initial_shop_state()
	ShopMenu.visible = true 
	get_tree().paused = true
