extends MenuButton

@onready var file_dialog_node = $"/root/Main/FileDialog1"
@onready var exit_dialog_node = $"/root/Main/ExitDialog"
# Called when the node enters the scene tree for the first time.
func _ready():
	self.get_popup().connect("id_pressed", _on_item_pressed)
	
	
func _on_item_pressed(id):
	match id:
		0:
			file_dialog_node.show()
		1:
			pass
		2:
			exit_dialog_node.on_display()
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass
