extends AcceptDialog


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	add_button("Github page",false,"github_link")


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass

func on_display():
	popup_centered()

# func on_github_link():
# 	OS.shell_open("https://github.com/snil4/StepEditor")


func _on_custom_action(action):
	if action == "github_link":
		OS.shell_open("https://github.com/snil4/StepEditor")
