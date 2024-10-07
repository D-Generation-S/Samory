extends Sprite2D

@export var max_width = 500.0
@export var max_heigth = 500.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func scale_now():
	scale = Vector2(max_width / texture.get_width(), max_heigth / texture.get_height())
