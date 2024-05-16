extends MenuButton

# var files: PackedStringArray

@export var recent_amount = 5

@onready var file_dialog_node = $"/root/Main/FileDialog1"
@onready var exit_dialog_node = $"/root/Main/ExitDialog"
@onready var editor_node = $"/root/Main/Editor"

const measure_scene = preload("res://Scenes/RecentMenu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():

	self.get_popup().connect("id_pressed", _on_item_pressed)
	editor_node.recent_added.connect(Callable(self, "save_recent"))

	build_menu()


func build_menu():

	get_popup().clear()

	get_popup().add_item("New", 6)
	get_popup().add_separator()

	get_popup().add_item("Open", 0)
	load_recent()
	get_popup().add_separator()

	get_popup().add_item("Save", 4)
	get_popup().add_item("Save As...", 5)
	get_popup().add_separator()

	get_popup().add_item("Exit", 2)
	
	
func _on_item_pressed(id):

	match id:
		0:
			file_dialog_node.show()

		2:
			exit_dialog_node.on_display()

		6:
			editor_node.new_file()

	print("ID: " + str(id))
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass


func save_recent(path: String):

	print("Adding recent")
	print("Path: " + path)

	var line_num = 0
	var recent_array = []
	# var found = false

	if not(FileAccess.file_exists("user://recents.save")):

		print("File is empty")

		var new_file = FileAccess.open("user://recents.save", FileAccess.WRITE)
		new_file.store_line(path)
		new_file.close()

		build_menu()
		return

	var save_read = FileAccess.open("user://recents.save", FileAccess.READ)

	while save_read.get_position() < save_read.get_length() and line_num < recent_amount: # iterate through all lines until the end of file is reached

		var line = save_read.get_line()
		line_num += 1
		print("Found line " + str(line_num))

		if line != path:
			recent_array.append(line)

	save_read.close()

	print("Saving line")
	
	var new_file = FileAccess.open("user://recents.save", FileAccess.WRITE)
	new_file.store_line(path)

	for recent in recent_array:
		new_file.store_line(recent)

	new_file.close()
	build_menu()


func load_recent():

	if not(FileAccess.file_exists("user://recents.save")):
		return

	var save_game = FileAccess.open("user://recents.save", FileAccess.READ)

	var recent_node = measure_scene.instantiate()

	while save_game.get_position() < save_game.get_length(): # iterate through all lines until the end of file is reached
		var line = save_game.get_line()
		recent_node.add_recent(line)
		
	get_popup().add_child(recent_node)
	get_popup().add_submenu_item("Open Recent","RecentMenu")
		
	save_game.close()
