extends Node2D

@onready var left_cube = $Cube1
@onready var right_cube = $Cube2
# Called when the node enters the scene tree for the first time.
func _ready():
	change_color(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass

func change_color(snap: int):
	show()
	var cur_color = Color(0.5,0.5,0.5,1)
	match snap:
		0:
			hide()
		1:
			cur_color = Color(1,0,0,1)
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
	left_cube.color  = cur_color
	right_cube.color = cur_color
	
