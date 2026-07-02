extends TextureRect

@export var animation_time: float = 0.5
@export_group("Pulse effect")
@export var should_pulse: bool = true
## Time required to get from min to max, also from max to min
@export var pulse_cycle_time: float = 0.8
@export var min_pulse_size: float = 0.8
@export var max_pulse_size: float = 1.2

var _should_be_shown: bool = false

func _ready() -> void:
	visible = false

func player_did_win(_color: ColorResource) -> void:
	_should_be_shown = true

func scoring_is_done() -> void:
	if not _should_be_shown:
		return
	offset_transform_scale = Vector2.ZERO
	visible = true
	var tween: Tween = create_tween()
	tween.tween_property(self, "offset_transform_scale", Vector2.ONE, animation_time)
	await tween.finished
	_pulse_icon()

func _pulse_icon() -> void:
	print("pulse start")
	if not should_pulse:
		return
	var pulse_tween: Tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(self, "offset_transform_scale", Vector2(max_pulse_size, max_pulse_size), pulse_cycle_time)
	pulse_tween.tween_property(self, "offset_transform_scale", Vector2(min_pulse_size, min_pulse_size), pulse_cycle_time)
	#tween.finished.connect(_pulse_icon)