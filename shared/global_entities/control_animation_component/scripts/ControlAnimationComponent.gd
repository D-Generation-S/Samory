class_name ControlAnimationComponent extends Node

signal enter_animation_done()

@export_group("Options")
@export var use_center: bool = true
## Set this value if you do not want to use the parent node
@export var controlled_node_override: Control = null
@export var properties: Array[String] = [
	"scale",
	"position",
	"size",
	"rotation",
	"self_modulate"
]
@export_group("Enter Animation")
@export var enter_animation_enabled: bool = true
## This will disable the enter animation if the target (parent) or custom one is not visible
@export var no_enter_animation_if_target_invisible: bool = true
## Component to await
@export var await_component: ControlAnimationComponent
@export var enter_values: ControlAnimation = null

@export_group("Hover Animation")
@export var animate_on_focus: bool = true
@export var hover_values: ControlAnimation = null

var target: Control
var default_values: Dictionary[String, Variant] = {}

const INSTANT_TRANSITION: Tween.TransitionType = Tween.TransitionType.TRANS_LINEAR

func _ready() -> void:
	target = get_parent()
	if controlled_node_override != null:
		target = controlled_node_override
	await get_tree().physics_frame
	_setup()

func _setup() -> void:
	default_values = {
		"scale" : target.scale,
		"position": target.position,
		"size": target.size,
		"rotation": target.rotation,
		"self_modulate": target.self_modulate
	}
	if use_center:
		target.pivot_offset = target.size / 2

	if hover_values != null:
		hover_values = hover_values.duplicate_deep()
		hover_values.setup(target)

	_animate_enter()
	_connect_signals()

func _animate_enter() -> void:
	if enter_values == null or not enter_animation_enabled:
		await get_tree().physics_frame
		enter_animation_done.emit()
		return
	enter_values = enter_values.duplicate_deep()
	enter_values.setup(target)
	var data: Dictionary[String, Variant] = enter_values.get_data()
	_add_tween(data, 0.0, true, enter_values.easing, INSTANT_TRANSITION)

	if await_component != null:
		await await_component.enter_animation_done
	if not target.visible and no_enter_animation_if_target_invisible:
		await get_tree().physics_frame
		enter_animation_done.emit()
		return

	await get_tree().create_timer(enter_values.delay).timeout
	if enter_values.animation_begin_sound != null:
		GlobalSoundBridge.play_sound(enter_values.animation_begin_sound)
	_add_tween(default_values,
			  enter_values.animation_time,
			  enter_values.parallel,
			  enter_values.easing,
			  enter_values.transition,
			  0.0,
			  _enter_done)
	await enter_animation_done

func _enter_done() -> void:
	enter_animation_done.emit()
	if enter_values.animation_end_sound != null:
		GlobalSoundBridge.play_sound(enter_values.animation_end_sound)

func _connect_signals() -> void:
	if hover_values != null:
		target.mouse_entered.connect(_add_tween_animation.bind(hover_values))
		target.mouse_exited.connect(_reset_tween_animation.bind(hover_values))
		if animate_on_focus:
			target.focus_entered.connect(_add_tween_animation.bind(hover_values))
			target.focus_exited.connect(_reset_tween_animation.bind(hover_values))

func _add_tween_animation(data: ControlAnimation) -> void:
	_add_tween(data.get_data(), data.animation_time, data.parallel, data.easing, data.transition)

func _reset_tween_animation(data: ControlAnimation) -> void:
	_add_tween(default_values, data.animation_time, data.parallel, data.easing, data.transition)

func _add_tween(target_properties: Dictionary[String, Variant],
				animation_time: float,
				parallel: bool,
				easing: Tween.EaseType,
				transition: Tween.TransitionType,
				delay: float = 0.0,
				end_method: Callable = func() -> void: return) -> void:
	if target_properties == null or not is_inside_tree() or target.is_queued_for_deletion():
		return
	await get_tree().create_timer(delay).timeout
	var tween: Tween = get_tree().create_tween()	
	for property: String in properties:
		if not target_properties.has(property):
			continue
		if parallel:
			tween.parallel()
		tween.tween_property(target, property, target_properties[property], animation_time).set_ease(easing).set_trans(transition)
	tween.finished.connect(_call_end_method.bind(end_method))
	tween.play()

func _call_end_method(end_method: Callable) -> void:
	if end_method == null or self == null:
		return
	end_method.call()	
