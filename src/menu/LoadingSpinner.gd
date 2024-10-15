extends Sprite2D

class_name LoadingSpinner

@export var spin_speed: float = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var real_spin_speed = spin_speed *  delta
	rotate(real_spin_speed)
	pass
