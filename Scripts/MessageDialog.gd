extends AcceptDialog

@onready var music_player_node = $"/root/Main/MusicPlayer"

# Called when the node enters the scene tree for the first time.
func _ready():
	music_player_node.on_error.connect(Callable(self, "on_error_message"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass
	

func on_error_message(error: String):
	title = "Error"
	set_text(error)
	
	popup_centered()
	
