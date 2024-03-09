extends Control

@onready var rect_node = get_node("MenuBar/ColorRect")
# Called when the node enters the scene tree for the first time.
func _ready():
	change_window()
	get_tree().get_root().size_changed.connect(Callable(self, "change_window"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func change_window():
	size = get_window().get_size_with_decorations()
	rect_node.set_size(Vector2(size.x, 41.0))
