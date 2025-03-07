class_name ControlAnimationResource extends Resource

@export_range(0.1, 1, 0.01, "suffix:seconds") var duration:float = 0.2

var animated_in: bool

func prepare_animation(control: Control):
	pass

func animate_in(tween: Tween, control: Control):
	animated_in = true

func animate_out(tween: Tween, control: Control):
	animated_in = false

func is_animated_in() -> bool:
	return animated_in

