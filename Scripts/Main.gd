extends Control

@onready var rect_node = $"MenuBar/ColorRect"
@onready var touch_node = $TouchButtons
@onready var editor_node = $Editor

# Called when the node enters the scene tree for the first time.
func _ready():
	if DisplayServer.screen_get_dpi() > 120:
		get_tree().root.content_scale_factor = DisplayServer.screen_get_dpi() / 120.0
		editor_node.initial_height *= DisplayServer.screen_get_dpi() / (120.0 * 3)
		editor_node.area2d_x_div = DisplayServer.screen_get_dpi() / 60.0
		get_tree().root.get_window().size *= DisplayServer.screen_get_dpi() / 120.0

	get_tree().get_root().size_changed.connect(Callable(self, "change_window"))
	change_window()
	editor_node.change_window()
	editor_node.initial = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func change_window():
	size = get_window().get_size_with_decorations()
	rect_node.set_size(Vector2(size.x, 41.0))


func set_touch_mode(state: bool):
	touch_node.visible = state
