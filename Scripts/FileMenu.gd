extends MenuButton


# Called when the node enters the scene tree for the first time.
func _ready():
	self.get_popup().connect("id_pressed", _on_item_pressed)
	
func _on_item_pressed(id):
	match id:
		0:
			$"/root/Main/FileDialog1".show()
		1:
			pass
		2:
			get_tree().quit()
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass
