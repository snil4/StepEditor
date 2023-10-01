extends MenuButton


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
			$"/root/Main/AboutDialog".on_display()
