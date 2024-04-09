extends Window

@onready var label_node = $Label2
@onready var main_node = $"/root/Main"
@onready var slider_node = $HSlider

var cur_speed: float


# Called when the node enters the scene tree for the first time.
# func _ready():
# 	slider_node.value = main_node.speed_mod
# 	set_label(main_node.speed_mod)


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass


func on_display():
	slider_node.value = main_node.speed_mod
	cur_speed = main_node.speed_mod
	set_label(main_node.speed_mod)
	popup_centered()
	show()


func _on_close_requested():
	hide()


func _on_h_slider_value_changed(value:float):
	cur_speed = value
	set_label(value)


func set_label(speed: float):
	label_node.text = str(speed) + "X"


func _on_button_pressed():
	main_node.speed_mod = cur_speed
	hide()
