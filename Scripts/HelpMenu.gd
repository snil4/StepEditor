extends MenuButton

@onready var about_node = get_node("/root/Main/AboutDialog")
# Called when the node enters the scene tree for the first time.
func _ready():
	self.get_popup().connect("id_pressed", _on_item_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass


func _on_item_pressed(id):
	
	match id:
		0:
			print("pass")

		1:
			about_node.on_display()
