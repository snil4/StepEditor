extends Control

## File managment variables
# Song properties
var properties = {}
# Path for the music file
var music_path
# Path for the charts file
var file_path
# Name of the charts file
var file_name
## Current chart properties
# Playing status
var is_playing = false
# Current location inside the measure
var cur_beat = 1.0
# Current location by measure
var cur_measure = 1
# Current BPM
var cur_bpm = 100.0
# Current measure division
var cur_div = 4
# Current snap value
var cur_snap: int = 0
var cur_mode: int = 4
@export var speed_mod = 2.0

# Numeric values of the cur_snap options
const snap_options = [0.015625 ,1, 0.5, 0.375, 0.25, 0.1875, 0.125, 0.0625, 0.09375, 0.03125, 0.015625]
const speed_pow = 50

@onready var rect_node = $"MenuBar/ColorRect"
@onready var touch_node = $TouchButtons
@onready var editor_node = $Editor
@onready var parser_node = $Parser


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
	parser_node.bpm_changed.connect(Callable(self, "set_bpm"))
	parser_node.mode_changed.connect(Callable(self, "set_mode"))
	parser_node.div_changed.connect(Callable(self, "set_div"))
	editor_node.snap_changed.connect(Callable(self, "set_snap"))
	editor_node.beat_changed.connect(Callable(self, "set_beat"))

	change_window()
	editor_node.change_window()
	parser_node.mode_changed.emit(5)

	load_game()
	
	editor_node.initial = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func set_bpm(bpm: float):
	cur_bpm = bpm


func set_beat(beat: float):
	cur_beat = beat
	measure_fix()


func set_mode(mode: int):
	cur_mode = mode


func set_div(div: int):
	cur_div = div


func set_snap(snap: int):
	cur_snap = snap
	cur_snap = clamp(cur_snap, 0, snap_options.size() - 1)


func measure_fix():

	if cur_beat < 1.0:
		cur_beat = (cur_div + 1) - snap_options[cur_snap]
		cur_measure -= 1

	elif cur_beat >= cur_div + 1:
		cur_beat = 1.0
		cur_measure += 1

	if cur_measure < 1:
		cur_beat = 1.0
		cur_measure = 1


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
