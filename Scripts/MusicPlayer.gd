extends AudioStreamPlayer

@onready var editor_node = $"/root/Main/Editor"
@onready var main_node = $"/root/Main"

signal on_error(message :String)

# Called when the node enters the scene tree for the first time.
func _ready():
	stream = null
	playing = false
	editor_node.play.connect(Callable(self, "set_play"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass


func set_play():

	if main_node.is_playing:

		if stream == null:
			main_node.is_playing = false
			on_error.emit("No music file found")
		
		else:
			var play_time: float = (((main_node.cur_measure - 1.0) * main_node.cur_div) \
				 + (main_node.cur_beat - 1.0)) / (main_node.cur_bpm / 60.0)
			play(play_time)

	else:
		playing = false


func set_music(file_name: String):

	if file_name.to_lower().ends_with(".mp3"):
		var file = FileAccess.open(file_name, FileAccess.READ)
		stream = AudioStreamMP3.new()
		stream.data = file.get_buffer(file.get_length)

	elif file_name.to_lower().ends_with(".ogg"):
		stream = AudioStreamOggVorbis.new()
		stream.load_from_file(file_name)

	elif file_name.to_lower().ends_with(".wav"):
		var file = FileAccess.open(file_name, FileAccess.READ)
		stream = AudioStreamWAV.new()
		stream.data = file.get_buffer(file.get_length)

	else:
		stream = null
