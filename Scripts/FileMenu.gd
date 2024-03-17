extends MenuButton

var files: PackedStringArray

@export var recent_amount = 5

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


func add_recent(path: String):

	for i in range(recent_amount,0,-1):
		files[i] = files[i - 1]

	files[0] = path
	save()


func save():

	var save_dict = {
		"files" : files,
    }

	return save_dict
