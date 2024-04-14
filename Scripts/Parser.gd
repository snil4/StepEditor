extends Node

var file
# var index: int
var line: String
var lines: PackedStringArray = PackedStringArray()
var file_path: String
var cur_property = []
var cur_split: int
var cur_measure: int
var cur_beat: float

@onready var measure_container_node = $"/root/Main/Editor/Area2D/MeasureContainer"
@onready var editor_node = $"/root/Main/Editor"
@onready var main_node = $"/root/Main"

signal music_loaded(file :String)
signal mode_changed(mode: int)
signal bpm_changed(bpm: float)
signal div_changed(div: int)

# Called when the node enters the scene tree for the first time.
# func _ready():
# 	pass


func load_music():

	file_path = main_node.properties["folder"] + "/" + main_node.properties["music"]

	if main_node.properties["Title"] == null:
		main_node.properties["Title"] = main_node.properties["music"].rsplit(".",true,1)[0]


	if main_node.properties["music"].to_lower().ends_with(".ogg"):
		main_node.properties["Title"] = main_node.properties["music"].trim_suffix(".ogg")

	elif main_node.properties["music"].to_lower().ends_with(".mp3"):
		main_node.properties["Title"] = main_node.properties["music"].trim_suffix(".mp3")

	elif main_node.properties["music"].to_lower().ends_with(".wav"):
		main_node.properties["Title"] = main_node.properties["music"].trim_suffix(".wav")



func load_chart():

	cur_measure=1
	cur_beat=1.0

	file_path = main_node.properties["folder"] + "/" + main_node.properties["chart"]

	if main_node.properties["chart"].ends_with(".ucs"):
		main_node.properties["type"] = "ucs"
		parse_ucs();

	else:
		main_node.properties["type"] = "sm"
		mode_changed.emit(4)

		file = open_file(file_path)

		# index = 0
		while not file.eof_reached(): # iterate through all lines until the end of file is reached
			line = file.get_line()
			line += " "
			lines.append(line)
			# print(String.num_int64(index) + "." + lines[index])

			# Header
			if line.begins_with("#"):
				cur_property = line.split(":",true,1)
				main_node.properties[cur_property[0].to_lower()] = cur_property[1].replace("; ", "")

			elif line.begins_with("//---------------"):
				break

			# index += 1

	file.close()
	print(main_node.properties)
	parse_details()


func parse_details() -> bool:
	return true


func parse_ucs():
	# Default single mode for pump
	mode_changed.emit(5)
	
	# Set global file path for the chart
	file_path = main_node.properties["folder"] + "/" + main_node.properties["chart"]
	print(file_path)
	file = open_file(file_path)

	# Main loop
	while not file.eof_reached(): # iterate through all lines until the end of file is reached
		line = file.get_line()

		# Header
		if line.begins_with(":"):
			cur_property = line.split("=",true,1)
			main_node.properties[cur_property[0].lstrip(":").to_lower()] = cur_property[1]
			
			match cur_property[0].lstrip(":").to_lower():
				
				"bpm":
					bpm_changed.emit(float(cur_property[1]))
					measure_container_node.clear_measures()
					editor_node.draw_measures()
					
				"beat":
					div_changed.emit(int(cur_property[1]))
					measure_container_node.clear_measures()
					editor_node.draw_measures()
					
				"split":
					cur_split=int(cur_property[1])
					
				"mode":
					if cur_property[1].to_lower() == "double":
						main_node.cur_mode = 10
						mode_changed.emit(10)
			
		# Chart
		elif line.length() > 0:
			var line_buffer = line.to_ascii_buffer()

			if line_buffer.size() > 0:
				for i in main_node.cur_mode:
					
					if   line_buffer[i] == 88:
						measure_container_node.add_note_node(i + 1,cur_measure,cur_beat)
					elif line_buffer[i] == 77:
						measure_container_node.add_note_node(i + 1,cur_measure,cur_beat)
					elif line_buffer[i] == 72:
						measure_container_node.add_note_node(i + 1,cur_measure,cur_beat)
					elif line_buffer[i] == 87:
						measure_container_node.add_note_node(i + 1,cur_measure,cur_beat)

				cur_beat += 1.0 / float(cur_split)
				measure_fix()


# Fix the current measure number based on the current beat
func measure_fix():

	if cur_beat < 1.0:
		cur_beat = (main_node.cur_div + 1) - 0.0125
		cur_measure -= 1
		
	elif cur_beat >= main_node.cur_div + 1:
		cur_beat = 1.0
		cur_measure += 1

	if cur_measure < 1:
		cur_beat = 1.0
		cur_measure = 1


func open_file(full_path: String) -> FileAccess:
	var _file = FileAccess.open(full_path, FileAccess.READ)

	# Write a backup file
	var _write_file = FileAccess.open(full_path + ".bak",FileAccess.WRITE)
	_write_file.store_string(_file.get_as_text())
	_write_file.close()

	return _file
