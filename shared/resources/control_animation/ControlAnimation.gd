class_name ControlAnimation extends Resource

@export_group("Transformation")
@export var animation_time: float = 0.2
@export var parallel: bool = true
@export var scale: Vector2 = Vector2.ZERO
@export var size: Vector2 = Vector2.ZERO
@export var position: Vector2 = Vector2.ZERO
@export var rotation_degree: float = 0.0
@export var modulate_add: Color = Color.WHITE

@export_group("Animation")
@export var delay: float = 0.0
@export var easing: Tween.EaseType
@export var transition: Tween.TransitionType

@export_group("Effects")
@export var animation_begin_sound: AudioStream
@export var animation_end_sound: AudioStream

var _data: Dictionary[String, Variant] = {}

func setup(target: Control) -> void:
	_data = {
		"scale" : target.scale + scale,
		"position": target.position + position,
		"size": target.size + size,
		"rotation": target.rotation + deg_to_rad(rotation_degree),
		"modulate": target.modulate * modulate_add
	}

func get_data() -> Dictionary[String, Variant]:
	return _data