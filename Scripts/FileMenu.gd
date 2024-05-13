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


func add_recent(path: String):

	for i in range(recent_amount,0,-1):
		files[i] = files[i - 1]

	files[0] = path
	save_recent()


func save_recent():

	var save_game = FileAccess.open("user://recents.save", FileAccess.WRITE)
	var save_dict = {
		"files" : files
    }

	# JSON provides a static method to serialized JSON string.
	var json_string = JSON.stringify(save_dict)

	# Store the save dictionary as a new line in the save file.
	save_game.store_line(json_string)
	save_game.close()


func load_recent():

	var save_game = FileAccess.open("user://recents.save", FileAccess.WRITE)

	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var node_data = json.get_data()

		# Firstly, we need to create the object and add it to the tree and set its position.
		files = node_data["files"]

	save_game.close()
