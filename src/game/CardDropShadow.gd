extends Sprite2D

@export var target_offset: Vector2 = Vector2(10, 10)
@export var focus_scale: float = 1.03
@export var animation_time: float = 0.2

var _current_tween: Tween = null
var _initial_position: Vector2 = Vector2.ZERO

func _ready():
	_initial_position = position;

func deck_changed(deck: MemoryDeckResource):
	if deck.card_back != null:
		texture = deck.card_back

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

	var value := _initial_position
	var new_scale := Vector2.ONE
	if animate_in:
		value = _initial_position + target_offset
		new_scale = Vector2(focus_scale, focus_scale)
	
	_current_tween.tween_property(self, "position", value, animation_time)
	_current_tween.parallel()
	_current_tween.tween_property(self, "scale", new_scale, animation_time)
	if not animate_in:
		_current_tween.finished.connect(func(): visible = false)
