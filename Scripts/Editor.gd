extends Node2D

# size and position variables
var note_size
var note_height
var note_scale = Vector2(1.0,1.0)
var chart_type: int = 4
const note_speed = 1
const initial_height = 50.0
const height_scale = 40.0
const snap_options = [0.015625 ,1, 0.5, 0.375, 0.25, 0.1875, 0.125, 0.0625, 0.09375, 0.03125, 0.015625]
const snap_names = ["Free" ,"4th", "8th", "12th", "16th", "24th", "32nd", "48th", "64th", "92nd", "128th"]

# File managment variables
var properties = {}
var music_path
var file_path
var file_name
var is_playing = false
var cur_beat = 1.0
var cur_measure = 1
var cur_bpm = 100.0
var div = 4
var snap: int = 0
var note_scene = load("res://Scenes/Note.tscn")

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
@onready var snap_node = $"/root/Main/CanvasLayer/SnapText"
@onready var notes_collection_node = $Area2D/MeasureContainer/NotesCollection


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)
	change_window()
	left_line_node.points[1].y = get_window().get_size_with_decorations().y
	right_line_node.points[1].y = get_window().get_size_with_decorations().y
	get_tree().get_root().size_changed.connect(Callable(self, "change_window"))
	draw_measures()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_playing:
		cur_beat += ((cur_bpm * 32.0) / 60.0) * delta
		measure_fix()
	measure_container_node.position.y = -((((cur_measure - 1) * 4) + cur_beat - 1) * (cur_bpm))


# Called every frame the window size is changed
func change_window():
	note_size = get_window().get_size_with_decorations()
	background_node.set_size(note_size)
	area2d_node.scale = note_scale
	
	left_line_node.points[1].y = note_size.y
	right_line_node.points[1].y = note_size.y
	# Scale the size of the arrows to not be bigger than the screen borders
	if note_size.x < area2d_node.scale.x * 500:
		area2d_node.scale.x = note_size.x / 500.0
		area2d_node.scale.y = note_size.x / 500.0

		left_line_node.points[1].y += note_size.y
		right_line_node.points[1].y += note_size.y
	# Scale the height of the receptors to compensate for the arrows's size
	note_height = area2d_node.scale.x * height_scale + initial_height
	area2d_node.position = Vector2(note_size.x / 3, note_height)

		

# Called on every key input
func _unhandled_input(event):
	if event is InputEventKey:
		# Zoom In
		if event.is_action_pressed("Zoom-In") and note_scale.x < 3.0:
			note_scale.x += 0.20
			note_scale.y += 0.20
			# print("Zoom")

		# Zoom Out
		elif event.is_action_pressed("Zoom-Out") and note_scale.x > 0.4:
			note_scale.x -= 0.20
			note_scale.y -= 0.20

		# Play/Stop
		elif Input.is_action_pressed("play") and music_path != null:
			is_playing = not(is_playing)
			# print("Zoom")

		# Scroll Down
		elif Input.is_action_pressed("Scroll-Down") and not(is_playing):
			cur_beat += snap_options[snap]
			while fmod(cur_beat, snap_options[snap]) != 0:
				cur_beat -= 0.015625

		# Scroll Up
		elif Input.is_action_pressed("Scroll-Up") and not(is_playing):
			cur_beat -= snap_options[snap]
			while fmod(cur_beat, snap_options[snap]) != 0:
				cur_beat += 0.015625

		# Snap Down
		elif Input.is_action_just_pressed("Snap_Down"):
			snap -= 1
		
		# Snap Up
		elif Input.is_action_just_pressed("Snap_Up"):
			snap += 1

		# Add Note 1
		elif Input.is_action_just_pressed("Insert_1"):
			add_note(1);

		# Add Note 2
		elif Input.is_action_just_pressed("Insert_2"):
			add_note(2);

		# Add Note 3
		elif Input.is_action_just_pressed("Insert_3"):
			add_note(3);

		# Add Note 4
		elif Input.is_action_just_pressed("Insert_4"):
			add_note(4);

		# Add Note 5
		elif Input.is_action_just_pressed("Insert_5"):
			add_note(5);

		# Add Note 6
		elif Input.is_action_just_pressed("Insert_6"):
			add_note(6);

		# Add Note 7
		elif Input.is_action_just_pressed("Insert_7"):
			add_note(7);

		# Add Note 8
		elif Input.is_action_just_pressed("Insert_8"):
			add_note(8);

		# Add Note 9
		elif Input.is_action_just_pressed("Insert_9"):
			add_note(9);

		# Add Note 3
		elif Input.is_action_just_pressed("Insert_10"):
			add_note(10);

		snap = clamp(snap, 0, snap_options.size() - 1)
		snap_node.set_text("Snap: " + snap_names[snap])
		cubes_node.change_color(snap)
		area2d_node.scale = note_scale
		note_height = area2d_node.scale.x * height_scale + initial_height
		area2d_node.position = Vector2(note_size.x / 3, note_height)
		measure_fix()
		print("measure: " + String.num_int64(cur_measure))
		print("beat: " + String.num(cur_beat))
		print("snap: " + String.num_int64(snap))


# Called on file selection
func _on_file_dialog_1_file_selected(path):
	file_dialog_node.hide()
	properties["folder"] = file_dialog_node.current_dir
	# print(properties["folder"])
	file_name = file_dialog_node.current_file
	# print(folder_path)

	if path.ends_with(".mp3") or path.ends_with(".ogg"):
		properties["music"] = file_name
		parser_node.load_music(properties)

	elif path.ends_with(".sm") or path.ends_with(".ssc") or path.ends_with(".ucs"):
		properties["chart"] = file_name
		parser_node.load_chart(properties)
		
	else:
		message_node.on_error_message("Can't open this file type")

func draw_measures():
	measure_container_node.change_props(cur_bpm,div,chart_type)
	for i in 100:
		for j in div:
			measure_container_node.draw_measure(i + 1, j + 1)

func add_note(num: int):
	var note_name = "Area2D/MeasureContainer/NotesCollection/note" + str(num) + "_" + str(cur_measure) + "_" + str(cur_beat)
	var note_node = get_node_or_null(note_name)
	if note_node != null:
		remove_child(note_node)
		print("note: " + note_name + " removed")
	else:
		measure_container_node.add_note_node(num,cur_measure,cur_beat)
		print("note: " + note_name + " added")

func measure_fix():
	if cur_beat < 1.0:
		cur_beat = div
		cur_measure -= 1
	elif cur_beat >= div + 1:
		cur_beat = 1.0
		cur_measure += 1
	if cur_measure < 1:
		cur_beat = 1.0
		cur_measure = 1



