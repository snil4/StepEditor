extends Node

var file
var index: int
var line: String
var lines: PackedStringArray = PackedStringArray()
var properties = {}
var file_path: String
var cur_property: PackedStringArray


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
	file = FileAccess.open(file_path, FileAccess.READ)
	if properties["chart"].ends_with(".ucs"):
		properties["type"] = "ucs"
		parse_ucs(original_properties);
	else:
		properties["type"] = "sm"
		index = 0
		while not file.eof_reached(): # iterate through all lines until the end of file is reached
			line = file.get_line()
			line += " "
			lines.append(line)
			# print(String.num_int64(index) + "." + lines[index])
			if line.begins_with("#"):
				cur_property = line.split(":",true,1)
				properties[cur_property[0].to_lower()] = cur_property[1].replace("; ", "")
			elif line.begins_with("//---------------"):
				break
			index += 1
		file.close()
		print(properties)
		parse_details()
	return properties


func parse_details() -> bool:
	return true

func parse_ucs(original_properties: Dictionary):
	properties = original_properties
	file_path = properties["folder"] + "/" + properties["chart"]
	file = FileAccess.open(file_path, FileAccess.READ)
	while not file.eof_reached(): # iterate through all lines until the end of file is reached
		line = file.get_line()
		if line.begins_with(":"):
			cur_property = line.split("=",true,1)
			properties[cur_property[0].to_lower()] = cur_property[1]
		else:
			for i in line.to_ascii_buffer():
				pass
