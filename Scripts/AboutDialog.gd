extends AcceptDialog


# Called when the node enters the scene tree for the first time.
func _ready():
	# On startup hide this window and add the buttons
	hide()
	add_button("Github page",false,"github_link")


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass

# Whenever the popup shows up center the popup on the window
func on_display():
	popup_centered_ratio(0.4)


# func on_github_link():
# 	OS.shell_open("https://github.com/snil4/StepEditor")

# Function for on-screen buttons
func _on_custom_action(action):
	# Link to this project's github
	if action == "github_link":
		OS.shell_open("https://github.com/snil4/StepEditor")
