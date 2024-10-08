extends TouchScreenButton

@onready var pressed_sprite = $PressedSprite
@onready var normal_sprite = $NormalSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_pressed():
	pressed_sprite.show()
	normal_sprite.hide()


func _on_released():
	normal_sprite.show()
	pressed_sprite.hide()
