extends Node2D

## Size and position variables
# Current window size
var window_size
var note_height
var note_scale = Vector2(1.0,1.0)
# Current chart type
var chart_type: int = 4
# Current chart type
var initial: bool = true
# Current chart type
var last_window_x
# Current scroll speed
@export var note_speed = 1
# Initial receptor height
@export var initial_height = 80.0
# The divider for the initial position of the area2d node on the screen
@export var area2d_x_div = 2
@export var min_note_scale = 0.4
@export var max_note_scale = 3.0
# Scaling for the height of the receptor
const height_scale = 40.0
# Numeric values of the cur_snap options
const snap_options = [0.015625 ,1, 0.5, 0.375, 0.25, 0.1875, 0.125, 0.0625, 0.09375, 0.03125, 0.015625]
# Names of the cur_snap options
const snap_names = ["Free" ,"4th", "8th", "12th", "16th", "24th", "32nd", "48th", "64th", "92nd", "128th"]
const music_file_types = [".ogg",".mp3"]
const chart_file_types = [".sm",".ssc",".ucs"]

const target4k_path  = "res://Scenes/Target4k"
const target5k_path  = "res://Scenes/Target5k"
const target8k_path  = "res://Scenes/Target8k"
const target10k_path = "res://Scenes/Target10k"

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

# Nodes
@onready var area2d_node = $Area2D
@onready var background_node = $Background
@onready var file_dialog_node = $"/root/Main/FileDialog1"
@onready var parser_node = $"/root/Main/Parser"
@onready var message_node = $"/root/Main/MessageDialog"
@onready var left_line_node = $Area2D/LineLeft
@onready var right_line_node = $Area2D/LineRight
@onready var measure_container_node = $Area2D/MeasureContainer
@onready var cubes_node = $Area2D/Cubes
@onready var snap_node = $CanvasLayer/SnapText
@onready var notes_collection_node = $Area2D/MeasureContainer/NotesCollection


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)

	last_window_x = get_window().get_size_with_decorations().x
	left_line_node.points[1].y = get_window().get_size_with_decorations().y
	right_line_node.points[1].y = get_window().get_size_with_decorations().y

	get_tree().get_root().size_changed.connect(Callable(self, "change_window"))
	get_viewport().files_dropped.connect(Callable(self, "_on_files_drop"))
	
	draw_measures()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if is_playing:
		cur_beat += ((cur_bpm * 32.0) / 60.0) * delta
		measure_fix()

	measure_container_node.position.y = -((((cur_measure - 1) * 4) + cur_beat - 1) * (cur_bpm))


# Called every frame the window size is changed
func change_window():

	window_size = get_window().get_size_with_decorations()
	background_node.set_size(window_size)
	area2d_node.scale = note_scale
	
	left_line_node.points[1].y = window_size.y
	right_line_node.points[1].y = window_size.y

	# Scale the size of the arrows to not be bigger than the screen borders
	if window_size.x < area2d_node.scale.x * 500:
		area2d_node.scale.x = window_size.x / 500.0
		area2d_node.scale.y = window_size.x / 500.0

		left_line_node.points[1].y += window_size.y
		right_line_node.points[1].y += window_size.y

	# Scale the height of the receptors to compensate for the arrows's size
	note_height = area2d_node.scale.x * height_scale + initial_height

	if initial:
		area2d_node.position = Vector2(window_size.x / area2d_x_div, note_height)

	else:
		area2d_node.position.x += (window_size.x - last_window_x) / 4

	last_window_x = window_size.x


# Called on every key input
func _input(event):

	if (event is InputEventMouseMotion and event.is_action_pressed("ui_select")) \
		or event is InputEventScreenDrag:
		area2d_node.position += event.relative


	if event is InputEventKey or event is InputEventScreenTouch:
		# Zoom In
		if event.is_action_pressed("Zoom-In"): 
			if note_scale.x < max_note_scale:
				note_scale.x += 0.20
				note_scale.y += 0.20

		# Zoom Out
		elif event.is_action_pressed("Zoom-Out"): 
			if note_scale.x > min_note_scale:
				note_scale.x -= 0.20
				note_scale.y -= 0.20

		# Play/Stop
		elif Input.is_action_pressed("play") and music_path != null:
			is_playing = not(is_playing)
			# print("Zoom")

		# Scroll Down
		elif Input.is_action_pressed("Scroll-Down") and not(is_playing):
			cur_beat += snap_options[cur_snap]
			while fmod(cur_beat, snap_options[cur_snap]) != 0:
				cur_beat -= 0.015625

		# Scroll Up
		elif Input.is_action_pressed("Scroll-Up") and not(is_playing):
			cur_beat -= snap_options[cur_snap]
			while fmod(cur_beat, snap_options[cur_snap]) != 0:
				cur_beat += 0.015625

		# Snap Down
		elif Input.is_action_just_pressed("Snap_Down"):
			cur_snap -= 1
		
		# Snap Up
		elif Input.is_action_just_pressed("Snap_Up"):
			cur_snap += 1

		# Add Note 1
		elif Input.is_action_just_pressed("Insert_1") && chart_type >= 1:
			add_note(1);

		# Add Note 2
		elif Input.is_action_just_pressed("Insert_2") && chart_type >= 2:
			add_note(2);

		# Add Note 3
		elif Input.is_action_just_pressed("Insert_3") && chart_type >= 3:
			add_note(3);

		# Add Note 4
		elif Input.is_action_just_pressed("Insert_4") && chart_type >= 4:
			add_note(4);

		# Add Note 5
		elif Input.is_action_just_pressed("Insert_5") && chart_type >= 5:
			add_note(5);

		# Add Note 6
		elif Input.is_action_just_pressed("Insert_6") && chart_type >= 6:
			add_note(6);

		# Add Note 7
		elif Input.is_action_just_pressed("Insert_7") && chart_type >= 7:
			add_note(7);

		# Add Note 8
		elif Input.is_action_just_pressed("Insert_8") && chart_type >= 8:
			add_note(8);

		# Add Note 9
		elif Input.is_action_just_pressed("Insert_9") && chart_type >= 9:
			add_note(9);

		# Add Note 3
		elif Input.is_action_just_pressed("Insert_10") && chart_type >= 10:
			add_note(10);


		cur_snap = clamp(cur_snap, 0, snap_options.size() - 1)
		snap_node.set_text("Snap: " + snap_names[cur_snap])
		cubes_node.change_color(cur_snap)
		note_height = area2d_node.scale.x * height_scale + initial_height
		# area2d_node.scale = note_scale
		#area2d_node.position = Vector2(window_size.x / area2d_x_div, note_height)
		measure_fix()

		if OS.is_debug_build():
			print("measure: " + String.num_int64(cur_measure))
			print("beat: " + String.num(cur_beat))
			print("cur_snap: " + String.num_int64(cur_snap))


# Called on dropping files to the editor
func _on_files_drop(files):
	var split = files[0].rsplit("/",false,1)
	print(split)

	file_name = split[1]
	properties["folder"] = split[0]

	load_file()


# Called on file selection
func _on_file_dialog_1_file_selected(_path):
	file_dialog_node.hide()

	for i in notes_collection_node.get_children():
		notes_collection_node.remove_child(i)
		i.queue_free()

	properties["folder"] = file_dialog_node.current_dir
	# print(properties["folder"])
	file_name = file_dialog_node.current_file
	# print(folder_path)

	load_file()


func load_file():
	var split = file_name.split(".",false,1)

	if music_file_types.has(split[0]):
		properties["music"] = file_name
		parser_node.load_music(properties)

	elif chart_file_types.has(split[0]):
		properties["chart"] = file_name
		parser_node.load_chart(properties)
		
	else:
		message_node.on_error_message("Can't open this file type")


# Draw all the measures in the scene
func draw_measures():
	measure_container_node.change_props(cur_bpm,cur_div)

	for i in 100:
		for j in cur_div:
			measure_container_node.draw_measure(i + 1, j + 1)


# Add a new note
func add_note(num: int):

	var note_name = ("Area2D/MeasureContainer/NotesCollection/note" \
	 	+ str(num) + "_" + str(cur_measure) + "_" + str(cur_beat)).replace(".","-")
	var note_node = get_node_or_null(note_name)

	if note_node != null:
		notes_collection_node.remove_child(note_node)
		note_node.queue_free()
		print("note: " + note_name + " removed")
	else:
		measure_container_node.add_note_node(num,cur_measure,cur_beat)
		print("note: " + note_name + " added")

# Fix the current measure number based on the current beat
func measure_fix():

	if cur_beat < 1.0:
		cur_beat = cur_div
		cur_measure -= 1

	elif cur_beat >= cur_div + 1:
		cur_beat = 1.0  + (cur_beat - cur_div)
		cur_measure += 1

	if cur_measure < 1:
		cur_beat = 1.0
		cur_measure = 1


func change_mode(mode: int):
	chart_type = mode
	measure_container_node.change_mode(mode)

	var target_node = $Area2D/Target
	area2d_node.remove_child(target_node)
	target_node.queue_free()

	match chart_type:
		4:
			target_node = load(target4k_path).instance()

		5:
			target_node = load(target5k_path).instance()

		8:
			target_node = load(target8k_path).instance()

		10:
			target_node = load(target10k_path).instance()

	area2d_node.add_child(target_node)
