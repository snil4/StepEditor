extends Node2D

# Cubes nodes
@onready var left_cube = $Cube1
@onready var right_cube = $Cube2

signal snap_changed(snap: int)

# Called when the node enters the scene tree for the first time.
func _ready():
	change_color(0)
	$"/root/Main/Editor".snap_changed.connect(Callable(self,"change_color"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass

# Function to change the cube's colors to match the correct snap
func change_color(_snap: int):
	# By default show the cubes and set the color gray
	show()
	var cur_color = Color(0.5,0.5,0.5,1)

	match $"/root/Main".cur_snap:
		# Free snap: Don't show cubes
		0:
			hide()

		# 4th: Red
		1:
			cur_color = Color(1,0,0,1)

		# 8th: Blue
		2:
			cur_color = Color(0,0,1,1)

		3:
			cur_color = Color(0.5,0,1,1)

		4:
			cur_color = Color(1,0.9,0,1)

		6:
			cur_color = Color(1,0.3,0.8,1)

		7:
			cur_color = Color(1,0.6,0,1)

	# Set the cubes color
	left_cube.color  = cur_color
	right_cube.color = cur_color
	
