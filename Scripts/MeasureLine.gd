extends Node2D

@onready var line_node = $Measure
@onready var label_node = $Label

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass

func new_measure(starting_point: float, end_point: float, num: int, width: float):

	line_node.points[0].x = starting_point
	line_node.points[1].x = end_point
	label_node.position.x = end_point + 30

	label_node.text = String.num_int64(num)

	if width < 3:
		label_node.hide()
		line_node.default_color = Color(0.4, 0.4, 0.4, 1)
		
	line_node.width = width

