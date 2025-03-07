extends TextureButton

@export var initial_position: Vector2
@export var pixels_to_move: float = 10
@export var animation_speed: float = 0.7

var animation_tween: Tween

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if visible == false:
		return
	animate()

func animate():
	if animation_tween != null and animation_tween.is_valid():
		return
	print("start animation")
	animation_tween = create_tween()
	animation_tween.tween_property(self, "position", Vector2(initial_position.x, initial_position.y + pixels_to_move), animation_speed)
	animation_tween.tween_property(self, "position", initial_position, animation_speed)