class_name ControlScaleAnimation extends ControlAnimationResource

@export_range(0,200, 0.01, "suffix:%") var scale_percentage: float = 105

var initial_scale: Vector2 = Vector2(1,1)

func prepare_animation(control: Control) -> void:
	control.pivot_offset = control.size / 2
	initial_scale = control.scale

func animate_in(tween: Tween, control: Control) -> void:
	super(tween, control)
	if !tween.is_valid():
		return
	tween.tween_property(control, "scale", initial_scale * get_scale_multiplier(), duration)

func animate_out(tween: Tween, control: Control) -> void:
	super(tween, control)
	if !tween.is_valid() or control.scale == initial_scale:
		return
	tween.tween_property(control, "scale", initial_scale, duration)

func get_scale_multiplier() -> float:
	return scale_percentage / 100