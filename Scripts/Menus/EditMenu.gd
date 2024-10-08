extends MenuButton

@onready var charts_scene = load("res://Scenes/ChartsMenu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():

	self.get_popup().connect("id_pressed", _on_item_pressed)

	build_menu()


func build_menu():

	get_popup().clear()

	get_popup().add_item("Song properties", 0)
	init_charts(1)
	get_popup().add_item("BPM and timing settings", 2)

func init_charts(id):
	var charts_node = charts_scene.instantiate()

	add_child(charts_node)
	get_popup().add_submenu_item("Select chart", "ChartsMenu", id)


func _on_item_pressed(id):
	
	match id:
		1:
			pass

	print("ID: " + str(id))
