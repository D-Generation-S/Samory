extends Path2D

@export var target_height: float = -350
@export var width_margin: float = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_curve()
	get_window().size_changed.connect(change_curve)

func change_curve() -> void:
	curve.clear_points()
	var window_size: Vector2i = get_window().size
	curve.add_point(Vector2(-width_margin, target_height))
	curve.add_point(Vector2(window_size.x + width_margin, target_height))

func _exit_tree() -> void:
	get_window().size_changed.disconnect(change_curve)