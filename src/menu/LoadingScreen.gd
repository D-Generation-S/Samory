extends Node2D

class_name LoadingScreen

@export var screen_message: Label

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_message.text = ""

func set_screen_message(new_text: String):
	screen_message.text = new_text

