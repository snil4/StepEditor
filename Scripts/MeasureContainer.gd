extends Node2D

var next_y: int
# Note scene for creating new note nodes
var note_scene = preload("res://Scenes/Note.tscn")
# Measure line scene for creating new measure line nodes
const measure_scene = preload("res://Scenes/MeasureLine.tscn")

@onready var notes_collection_node = $NotesCollection
@onready var measures_collection_node = $MeasuresCollection
@onready var editor_node = $"/root/Main/Editor"
@onready var main_node = $"/root/Main"


# Called when the node enters the scene tree for the first time.
# func _ready():
# 	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass


# func change_mode(mode: int):
# 	cur_mode = mode


# func change_props(bpm: float, div: int):
# 	cur_bpm = bpm
# 	cur_div = div


func clear_measures():
	for i in measures_collection_node.get_children():
		measures_collection_node.remove_child(i)
		i.queue_free()


func draw_measure(measure: int, beat: float):

	var width = 3
	var measure_node = measure_scene.instantiate()
	measures_collection_node.add_child(measure_node)
	
	if beat != 1:
		width = 1

	measure_node.position.y = 0

	if measure > 1 or beat > 1:
		# measure_node.position.y = (((measure - 1) * 4) + beat - 1) * (main_node.cur_bpm / main_node.speed_mod)
		measure_node.position.y = (((measure - 1) * 4) + beat - 1) * (main_node.speed_mod * main_node.speed_pow)

	measure_node.new_measure(-150, 150,measure, width)


func add_note_node(num: int, measure: int, beat: float):

	if num > main_node.cur_mode:
		return

	var note_node = note_scene.instantiate()
	note_node.set_name(("note" + str(num) + "_" + str(measure)
						 + "_" + str(beat)).replace(".","-"))

	var animation_node = note_node.get_node("AnimatedSprite2D")
	match main_node.cur_mode:

		4:
			animation_node.set_animation("4k_1")
			# note_node.set_position(Vector2(-165 + 65 * num,(((measure - 1) * 4) + beat - 1) * (main_node.cur_bpm / main_node.speed_mod)))
			note_node.set_position(Vector2(-165 + 65 * num,(((measure - 1) * 4) + beat - 1) * (main_node.speed_mod * main_node.speed_pow)))

			match num:
				1:
					animation_node.set_rotation_degrees(90)

				3:
					animation_node.set_rotation_degrees(180)

				4:
					animation_node.set_rotation_degrees(-90)

		5:
			# note_node.set_position(Vector2(-193 + 64 * num,(((measure - 1) * 4) + beat - 1) * (main_node.cur_bpm / main_node.speed_mod)))
			note_node.set_position(Vector2(-193 + 64 * num,(((measure - 1) * 4) + beat - 1) * (main_node.speed_mod * main_node.speed_pow)))

			if num > 3:
				animation_node.flip_h = true
				animation_node.set_animation("5k_" + str(num * -1 + 6))

			else:
				animation_node.set_animation("5k_" + str(num))

	notes_collection_node.add_child(note_node)
