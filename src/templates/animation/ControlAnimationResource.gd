class_name ControlAnimationResource extends Resource

@export_range(0.1, 1, 0.01, "suffix:seconds") var duration:float = 0.2

var animated_in: bool

func prepare_animation(_control: Control) -> void:
	pass

func animate_in(_tween: Tween, _control: Control) -> void:
	animated_in = true

func animate_out(_tween: Tween, _control: Control) -> void:
	animated_in = false

func is_animated_in() -> bool:
	return animated_in

