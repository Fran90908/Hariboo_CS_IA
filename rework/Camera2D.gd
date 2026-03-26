# Inside your Camera2D node
extends Camera2D

func _ready():
	# Horizontal limits
	limit_left = -1000
	limit_right = 3000

	# Vertical limits
	limit_top = -600
	limit_bottom = 2000
