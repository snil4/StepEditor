extends Node

var file
var index
var line: String
var lines: PackedStringArray
# Called when the node enters the scene tree for the first time.
func _ready():
	lines = PackedStringArray()

func load_file(file_path: String):
	file = FileAccess.open(file_path, FileAccess.READ)
	index = 0
	while not file.eof_reached(): # iterate through all lines until the end of file is reached
		line = file.get_line()
		line += " "
		lines.append(line)
		print(String.num_int64(index) + "." + lines[index])
		if !parse_details():
			break
		index += 1
	file.close()


func parse_details() -> bool:
	return true