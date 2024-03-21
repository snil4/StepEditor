extends Node2D

## Size and position variables
# Current window size
var window_size
var note_height
var note_scale = Vector2(1.0,1.0)
# Is this inisialization?
var initial: bool = true
# last window size for comparison
var last_window_x
# Initial receptor height
@export var initial_height = 80.0
# The divider for the initial position of the area2d node on the screen
@export var area2d_x_div = 2
@export var min_note_scale = 0.4
@export var max_note_scale = 3.0
# Scaling for the height of the receptor
const height_scale = 40.0
# Names of the cur_snap options
const snap_names = ["Free" ,"4th", "8th", "12th", "16th", "24th", "32nd", "48th", "64th", "92nd", "128th"]
const music_file_types = ["ogg","mp3"]
const chart_file_types = ["sm","ssc","ucs"]

const target4k_path  = "res://Scenes/Targets/Target4k.tscn"
const target5k_path  = "res://Scenes/Targets/Target5k.tscn"
const target8k_path  = "res://Scenes/Targets/Target8k.tscn"
const target10k_path = "res://Scenes/Targets/Target10k.tscn"

# Nodes
@onready var area2d_node = $Area2D
@onready var main_node = $"/root/Main"
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

signal snap_changed(snap :int)
signal beat_changed(beat :int)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)

	last_window_x = get_window().get_size_with_decorations().x
	left_line_node.points[1].y = get_window().get_size_with_decorations().y
	right_line_node.points[1].y = get_window().get_size_with_decorations().y

	get_tree().get_root().size_changed.connect(Callable(self, "change_window"))
	get_viewport().files_dropped.connect(Callable(self, "_on_files_drop"))
	parser_node.mode_changed.connect(Callable(self, "set_mode"))
	
	draw_measures()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if main_node.is_playing:
		main_node.cur_beat += ((main_node.cur_bpm * 32.0) / 60.0) * delta

	# measure_container_node.position.y = -((((main_node.cur_measure - 1) * 4) + main_node.cur_beat - 1) * (main_node.cur_bpm / main_node.speed_mod))
	measure_container_node.position.y = -((((main_node.cur_measure - 1) * 4) + main_node.cur_beat - 1) * (100 / main_node.speed_mod))


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
		elif Input.is_action_pressed("play") and main_node.music_path != null:
			main_node.is_playing = not(main_node.is_playing)
			# print("Zoom")

		# Scroll Down
		elif Input.is_action_pressed("Scroll-Down") and not(main_node.is_playing):
			var beat = main_node.cur_beat + main_node.snap_options[main_node.cur_snap]
			while fmod(beat, main_node.snap_options[main_node.cur_snap]) != 0:
				beat -= 0.015625
			
			beat_changed.emit(beat)

		# Scroll Up
		elif Input.is_action_pressed("Scroll-Up") and not(main_node.is_playing):
			var beat = main_node.cur_beat - main_node.snap_options[main_node.cur_snap]
			while fmod(beat, main_node.snap_options[main_node.cur_snap]) != 0:
				beat += 0.015625

			beat_changed.emit(beat)

		# Snap Down
		elif Input.is_action_just_pressed("Snap_Down"):
			set_snap(main_node.cur_snap - 1)
		
		# Snap Up
		elif Input.is_action_just_pressed("Snap_Up"):
			set_snap(main_node.cur_snap + 1)

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


		note_height = area2d_node.scale.x * height_scale + initial_height
		# area2d_node.scale = note_scale
		#area2d_node.position = Vector2(window_size.x / area2d_x_div, note_height)

		if OS.is_debug_build():
			print("measure: " + String.num_int64(main_node.cur_measure))
			print("beat: " + String.num(main_node.cur_beat))
			print("cur_snap: " + String.num_int64(main_node.cur_snap))


func set_snap(snap: int):
		snap_changed.emit(snap)
		snap_node.set_text("Snap: " + snap_names[main_node.cur_snap])


# Called on dropping files to the editor
func _on_files_drop(files):
	main_node.properties = {}

	var split = files[0].rsplit("/",false,1)
	print(split)

	main_node.file_name = split[1]
	main_node.properties["folder"] = split[0]

	load_file()


# Called on file selection
func _on_file_dialog_1_file_selected(_path):
	main_node.properties = {}
	file_dialog_node.hide()

	for i in notes_collection_node.get_children():
		notes_collection_node.remove_child(i)
		i.queue_free()

	main_node.properties["folder"] = file_dialog_node.current_dir
	# print(properties["folder"])
	main_node.file_name = file_dialog_node.current_file
	# print(folder_path)

	load_file()


func load_file():
	var split = main_node.file_name.split(".",false,1)

	if music_file_types.has(split[1]):
		main_node.properties["music"] = main_node.file_name
		parser_node.load_music()

	elif chart_file_types.has(split[1]):
		main_node.properties["chart"] = main_node.file_name
		parser_node.load_chart()
		
	else:
		message_node.on_error_message("Can't open this file type")


# Draw all the measures in the scene
func draw_measures():
	measure_container_node.clear_measures()

	for i in 100:
		for j in main_node.cur_div:
			measure_container_node.draw_measure(i + 1, j + 1)


# Add a new note
func add_note(num: int):

	var note_name = ("Area2D/MeasureContainer/NotesCollection/note" \
	 	+ str(num) + "_" + str(main_node.cur_measure) + "_" + str(main_node.cur_beat)).replace(".","-")
	var note_node = get_node_or_null(note_name)

	if note_node != null:
		notes_collection_node.remove_child(note_node)
		note_node.queue_free()
		print("note: " + note_name + " removed")
	else:
		measure_container_node.add_note_node(num,main_node.cur_measure,main_node.cur_beat)
		print("note: " + note_name + " added")


func set_mode(mode: int):
	var target_node = $Area2D/Target
	area2d_node.remove_child(target_node)
	target_node.queue_free()

	match mode:
		4:
			target_node = load(target4k_path).instantiate()

		5:
			target_node = load(target5k_path).instantiate()

		8:
			target_node = load(target8k_path).instantiate()

		10:
			target_node = load(target10k_path).instantiate()

	area2d_node.add_child(target_node)
