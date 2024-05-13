extends ConfirmationDialog


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass

func on_display():
	popup_centered()
	show()

func _on_confirmed():
	get_tree().quit()


func _on_canceled():
	hide()
