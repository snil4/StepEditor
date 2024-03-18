extends Node

var file
# var index: int
var line: String
var lines: PackedStringArray = PackedStringArray()
var properties = {}
var file_path: String
var cur_property: PackedStringArray
var cur_mode: int = 4
var cur_measure: int
var cur_beat: float
var cur_split: float
var cur_div: int
var cur_bpm: float

@onready var measure_container_node = $"/root/Main/Editor/Area2D/MeasureContainer"
@onready var editor_node = $"/root/Main/Editor"


# Called when the node enters the scene tree for the first time.
# func _ready():
# 	pass


func load_music(original_properties: Dictionary) -> Dictionary:

	properties = original_properties
	file_path = properties["folder"] + "/" + properties["music"]

	if properties["music"].ends_with(".ogg"):
		properties["Title"] = properties["music"].trim_suffix(".ogg")

	elif properties["music"].ends_with(".mp3"):
		properties["Title"] = properties["music"].trim_suffix(".mp3")

	return properties


func load_chart(original_properties: Dictionary) -> Dictionary:
	properties = original_properties
	file_path = properties["folder"] + "/" + properties["chart"]

	if properties["chart"].ends_with(".ucs"):
		properties["type"] = "ucs"
		parse_ucs(original_properties);

	else:
		properties["type"] = "sm"
		
		file = FileAccess.open(file_path, FileAccess.READ)
		# index = 0
		while not file.eof_reached(): # iterate through all lines until the end of file is reached
			line = file.get_line()
			line += " "
			lines.append(line)
			# print(String.num_int64(index) + "." + lines[index])

			# Header
			if line.begins_with("#"):
				cur_property = line.split(":",true,1)
				properties[cur_property[0].to_lower()] = cur_property[1].replace("; ", "")

			elif line.begins_with("//---------------"):
				break

			# index += 1
		file.close()
		print(properties)
		parse_details()

	return properties


func parse_details() -> bool:
	return true


func parse_ucs(original_properties: Dictionary):
	# Set global properties list
	properties = original_properties

	# Initialize measure and beat count
	cur_measure=1
	cur_beat=1.0

	# Default single mode for pump
	cur_mode = 5
	editor_node.change_mode(5)
	
	# Set global file path for the chart
	file_path = properties["folder"] + "/" + properties["chart"]
	print(file_path)
	file = FileAccess.open(file_path, FileAccess.READ)

	# Main loop
	while not file.eof_reached(): # iterate through all lines until the end of file is reached
		line = file.get_line()

		# Header
		if line.begins_with(":"):
			cur_property = line.split("=",true,1)
			properties[cur_property[0].lstrip(":").to_lower()] = cur_property[1]
			
			match cur_property[0].lstrip(":").to_lower():
				
				"bpm":
					cur_bpm=float(cur_property[1])
					editor_node.set_bpm(float(cur_property[1]))
					
				"beat":
					editor_node.set_div(int(cur_property[1]))
					cur_div=int(cur_property[1])
					
				"split":
					cur_split=int(cur_property[1])
					
				"mode":
					if cur_property[1].to_lower() == "double":
						cur_mode = 10
						editor_node.change_mode(10)
			
		# Chart
		elif line.length() > 0:
			var line_buffer = line.to_ascii_buffer()

			if line_buffer.size() > 0:
				for i in cur_mode:
					
					if line_buffer[i] == 88:
						measure_container_node.add_note_node(i + 1,cur_measure,cur_beat)

			cur_beat += 1.0 / float(cur_split)
			measure_fix()


# Fix the current measure number based on the current beat
func measure_fix():

	if cur_beat < 1.0:
		cur_beat = cur_div
		cur_measure -= 1
		
	elif cur_beat >= cur_div + 1:
		cur_beat = 1.0 + (cur_beat - cur_div)
		cur_measure += 1


	if cur_measure < 1:
		cur_beat = 1.0
		cur_measure = 1
