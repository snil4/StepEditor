extends PopupMenu

@onready var editor_node = $"/root/Main/Editor"


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


func add_recent(path: String):
	add_item(path)

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass


func _on_index_pressed(index:int):
	editor_node.load_recent.emit(get_item_text(index))
