extends ColorRect

@export var target_offset: Vector2 = Vector2(10, 10)
@export var animation_time: float = 0.2

var _current_tween: Tween = null

func _ready():
	position = Vector2.ZERO

func got_focus():
	
	_animate_shadow(true)	

func lost_focus():
	_animate_shadow(false)

func _animate_shadow(animate_in: bool):
	if animate_in:
		visible = true
	if _current_tween != null:
		_current_tween.stop()
	_current_tween = create_tween()

	var value := Vector2.ZERO
	if animate_in:
		value = target_offset
	_current_tween.tween_property(self, "position", value, animation_time)
	if not animate_in:
		_current_tween.finished.connect(func(): visible = false)
