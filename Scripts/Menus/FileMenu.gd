extends MenuButton

var files: PackedStringArray

@export var recent_amount = 5

@onready var file_dialog_node = $"/root/Main/FileDialog1"
@onready var exit_dialog_node = $"/root/Main/ExitDialog"
@onready var editor_node = $"/root/Main/Editor"

# Called when the node enters the scene tree for the first time.
func _ready():
	self.get_popup().connect("id_pressed", _on_item_pressed)

	load_recent()
	
	
func _on_item_pressed(id):

	match id:
		0:
			file_dialog_node.show()

		1:
			pass

		2:
			exit_dialog_node.on_display()

		6:
			editor_node.new_file()
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass


func save_recent(path: String):

	var line_num = 0
	var recent_array = []
	var found = false

	if not(FileAccess.file_exists("user://recents.save")):
		var new_file = FileAccess.open("user://recents.save", FileAccess.WRITE)
		new_file.store_line(path)
		new_file.close()
		return

	var save_read = FileAccess.open("user://recents.save", FileAccess.READ)

	while not(save_read.eof_reached()) and line_num < recent_amount: # iterate through all lines until the end of file is reached

		var line = save_read.get_line()
		line_num += 1

		if line == path:
			found = true

		else:
			recent_array.append(line)

	save_read.close()

	if found:
		var new_file = FileAccess.open("user://recents.save", FileAccess.WRITE)
		new_file.store_line(path)

		for recent in recent_array:
			new_file.store_line(recent)

		new_file.close()


func load_recent():

	if not(FileAccess.file_exists("user://recents.save")):
		return

	var save_game = FileAccess.open("user://recents.save", FileAccess.READ)

	while not save_game.eof_reached(): # iterate through all lines until the end of file is reached
		var line = save_game.get_line()


	save_game.close()
