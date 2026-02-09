extends RichTextLabel

signal counter_done()

@export var animation_time: float = 2

var _current_number: int = 0
var _fake_number: int = 0
var _is_winning: bool = false
var _winner_color: ColorResource

func is_winning_player(color: ColorResource) -> void:
	_is_winning = true
	_winner_color = color

func set_counter_target(target_number: int) -> void:
	if target_number == 0:
		text = str(target_number)
		return
	_current_number = target_number
	var tween: Tween = create_tween()
	tween.tween_method(_animation_step, _fake_number, _current_number, animation_time)

func _animation_step(value: int) -> void:
	_fake_number = value
	if _fake_number == _current_number:
		counter_done.emit()
	text = str(value)
	if _is_winning and _winner_color != null:
		text = "%s%s[/color]" % [_winner_color.get_color_bb_code(), text]