extends Control

@onready var rect_node = $"MenuBar/ColorRect"
@onready var touch_node = $TouchButtons
@onready var editor_node = $Editor

# Called when the node enters the scene tree for the first time.
func _ready():

	if DisplayServer.screen_get_dpi() > 120:
		get_tree().root.content_scale_factor = DisplayServer.screen_get_dpi() / 120.0

		editor_node.initial_height *= DisplayServer.screen_get_dpi() / (120.0 * 3)
		editor_node.area2d_x_div = DisplayServer.screen_get_dpi() / 60.0

		get_tree().root.get_window().size *= DisplayServer.screen_get_dpi() / 120.0
		get_tree().root.get_window().position = Vector2(DisplayServer.screen_get_size().x / 
														(DisplayServer.screen_get_dpi() / 50.0),
														DisplayServer.screen_get_size().y / 
														(DisplayServer.screen_get_dpi() / 50.0))

	get_tree().get_root().size_changed.connect(Callable(self, "change_window"))
	change_window()
	editor_node.change_window()

	load_game()
	
	editor_node.initial = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func change_window():
	size = get_window().get_size_with_decorations()
	rect_node.set_size(Vector2(size.x, 41.0))


func set_touch_mode(state: bool):
	touch_node.visible = state


func save_game():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)

	
# Note: This can be called from anywhere inside the tree. This function
# is path independent.
func load_game():

	# If no save file found then create a new one
	if not FileAccess.file_exists("user://savegame.save"):
		FileAccess.open("user://savegame.save", FileAccess.WRITE)
		save_game()
		return # Error! We don't have a save to load.

	# Get all saveable nodes in the scene
	var save_nodes = get_tree().get_nodes_in_group("Persist")

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

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
		var new_object = $node_data["filename"].load()
		get_node(node_data["parent"]).add_child(new_object)
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])

		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, node_data[i])
