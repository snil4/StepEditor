extends AcceptDialog


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass
	

func on_error_message(error: String):
	title = "Error"
	set_text(error)
	
	popup_centered()
	
