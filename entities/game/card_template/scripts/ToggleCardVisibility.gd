extends Sprite2D

class_name ToggleCardVisibility

signal ready_for_removal()
signal fully_hidden()
signal fully_shown()
signal hide_started()

enum VisibilityEnum
{
	HIDDEN,
	TRANSITION,
	SHOWN
}

@export var animation_time: float = 0.4
@export var focus_animation_time: float = 0.2
@export var focus_scale: float = 1.03
@export var toggle_material: ShaderMaterial
@export var focus_material: ShaderMaterial
@export var enforced_back_color: Color = Color(0,0,0,1)

var _internal_toggle_material: ShaderMaterial
var _internal_focus_material: ShaderMaterial

## The card is the current focus of the player
var _current_focus: bool = false

var removal_requested: bool = false
var can_remove: bool = false
var removal_planned: bool = false
#var currently_ai: bool = false

var animation_tween: Tween = null
var _focus_tween: Tween = null

var visibility: VisibilityEnum = VisibilityEnum.HIDDEN

func _ready() -> void:
	visible = true
	_internal_focus_material = focus_material.duplicate_deep()
	_internal_toggle_material = toggle_material.duplicate_deep()
	# This ensures that each instance does get it's own shader instance
	set_shader_material(_internal_toggle_material)

func deck_changed(deck: MemoryDeckResource) -> void:
	var real_texture: Texture2D = deck.get_back_image()
	if real_texture == null:
		return

	texture = real_texture
	return

## This method will hide a fully shown card
func toggle_on() -> void:
	can_remove = false
	if is_hidden():
		return
		
	if material is ShaderMaterial:
		material.set_shader_parameter("threshold", 1.0)	
	if animation_tween != null:
		animation_tween.kill()
	hide_started.emit()
	lost_focus()
	animation_tween = create_tween()
	visibility = VisibilityEnum.TRANSITION
	animation_tween.tween_method(update_toggle_material, 1.0, 0.0, animation_time)
	animation_tween.finished.connect(func() -> void: _animation_finished(true))
	if _current_focus:
		set_shader_material(_internal_toggle_material)

func _animation_finished(should_hide: bool) -> void:
	if should_hide:
		fully_hidden.emit()
		visibility = VisibilityEnum.HIDDEN
	if not should_hide:
		fully_shown.emit()
		visibility = VisibilityEnum.SHOWN
		can_remove = true

## This method will show a fully hidden card
func toggle_off() -> void:
	if animation_tween != null:
		animation_tween.kill()
	if material is ShaderMaterial:
		material.set_shader_parameter("threshold", 0.0)	
	animation_tween = create_tween()
	visibility = VisibilityEnum.TRANSITION
	animation_tween.tween_method(update_toggle_material, 0.0, 1.0, animation_time)
	animation_tween.finished.connect(func() -> void: _animation_finished(false))
	if _current_focus:
		set_shader_material(_internal_toggle_material)

func update_toggle_material(progress: float) -> void:
	if material is ShaderMaterial:
		material.set_shader_parameter("threshold", progress)	

func focus_changed(new_focus: bool) -> void:
	if new_focus:
		is_focused()
	else:
		lost_focus()

func is_focused() -> void:
	if animation_tween != null && animation_tween.is_running():
		return
	if visibility == VisibilityEnum.TRANSITION:
		return

	_current_focus = true
	set_shader_material(_internal_focus_material)
	_animate_focus(focus_scale)

func lost_focus() -> void:
	_current_focus = false
	set_shader_material(_internal_toggle_material)

	_animate_focus(1.0)

func _animate_focus(new_scale: float) -> void:
	_focus_tween = create_tween()
	_focus_tween.tween_property(self, "scale", Vector2(new_scale, new_scale), focus_animation_time)

func set_shader_material(new_material: Material) -> void:
	material = new_material

func is_hidden() -> bool:
	return visibility == VisibilityEnum.HIDDEN

func is_fully_shown() -> bool:
	return visibility == VisibilityEnum.SHOWN

func is_currently_in_focus() -> bool:
	return _current_focus

func remove_from_board() -> void:
	removal_requested = true

func removal_planed() -> void:
	removal_planned = true

func _process(_delta: float) -> void:
	if removal_planned && can_remove:
		ready_for_removal.emit()
		queue_free()
