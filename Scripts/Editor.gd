extends Node2D

# size and position variables
var note_size
var note_scale
var note_height
var note_speed
var initial_height
var height_scale

# File managment variables
var folder_path
var music_path
var file_path
var file_name

# Called when the node enters the scene tree for the first time.
func _ready():
	initial_height = 50.0
	height_scale = 40.0
	note_scale = Vector2(1.0,1.0)
	note_speed = 1
	set_process_input(true)
	change_window()
	get_tree().get_root().size_changed.connect(Callable(self, "change_window"))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass

# Called every frame the window size is changed
func change_window():
	note_size = get_window().get_size_with_decorations()
	$Control/Background.set_size(note_size)
	$Area2D.scale = note_scale
	# Scale the size of the arrows to not be bigger than the screen borders
	if note_size.x < $Area2D.scale.x * 500:
		$Area2D.scale.x = note_size.x / 500.0
		$Area2D.scale.y = note_size.x / 500.0
	# Scale the height of the receptors to compensate for the arrows's size
	note_height = $Area2D.scale.x * height_scale + initial_height
	$Area2D.position = Vector2(note_size.x / 3, note_height)
		
# Called on every key input
func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_action_pressed("Zoom-In") and note_scale.x < 3.0:
			note_scale.x += 0.20
			note_scale.y += 0.20
			# print("Zoom")
		if event.is_action_pressed("Zoom-Out") and note_scale.x > 0.4:
			note_scale.x -= 0.20
			note_scale.y -= 0.20
			# print("Zoom")
		$Area2D.scale = note_scale
		note_height = $Area2D.scale.x * height_scale + initial_height
		$Area2D.position = Vector2(note_size.x / 3, note_height)

# Called on file selection
func _on_file_dialog_1_file_selected(path):
	$"/root/Main/FileDialog1".hide()
	folder_path = $"/root/Main/FileDialog1".current_dir
	file_name = $"/root/Main/FileDialog1".current_file
	# print(folder_path)
	if path.ends_with(".mp3") or path.ends_with(".ogg"):
		music_path = path
	elif path.ends_with(".sm") or path.ends_with(".ssc"):
		file_path = path
		$"/root/Main/Parser".load_file(path)
	else:
		$"/root/Main/MessageDialog".on_error_message("Can't open this file type")
	
