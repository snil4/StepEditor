extends PopupMenu


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


func add_chart(name: String):
	add_item(name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass


func _on_index_pressed(index:int):
	pass
	#change_chart(index)
