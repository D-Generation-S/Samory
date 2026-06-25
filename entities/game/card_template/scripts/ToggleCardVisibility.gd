extends Sprite2D

class_name ToggleCardVisibility

signal ready_for_removal()
signal fully_hidden()
signal fully_shown()
signal hide_started()
signal in_focus()
signal focus_lost()

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

var currently_in_focus: bool = false

var collider: Area2D
var removal_requested: bool = false
var can_remove: bool = false
var removal_planned: bool = false
var currently_ai: bool = false

var animation_tween: Tween = null
var _focus_tween: Tween = null

var fix_image_thread: Thread

var visibility: VisibilityEnum = VisibilityEnum.HIDDEN

func _ready() -> void:
	collider = %Collider
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

# This method will hide a fully shown card
func toggle_on() -> void:
	print("toggle on")
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
	if currently_in_focus:
		set_shader_material(_internal_toggle_material)

func _animation_finished(should_hide: bool) -> void:
	if should_hide:
		fully_hidden.emit()
		visibility = VisibilityEnum.HIDDEN
		print("hidden")
	if not should_hide:
		fully_shown.emit()
		visibility = VisibilityEnum.SHOWN
		can_remove = true
		print("shown")

func freeze_card() -> void:
	collider.visible = false
	
func unfreeze_card() -> void:
	if currently_ai:
		return
	collider.visible = true

# This method will show a fully hidden card
func toggle_off() -> void:
	print("toggle off")
	if animation_tween != null:
		animation_tween.kill()
	if material is ShaderMaterial:
		material.set_shader_parameter("threshold", 0.0)	
	animation_tween = create_tween()
	visibility = VisibilityEnum.TRANSITION
	animation_tween.tween_method(update_toggle_material, 0.0, 1.0, animation_time)
	animation_tween.finished.connect(func() -> void: _animation_finished(false))
	if currently_in_focus:
		set_shader_material(_internal_toggle_material)

func update_toggle_material(progress: float) -> void:
	if material is ShaderMaterial:
		material.set_shader_parameter("threshold", progress)	

func is_focused() -> void:
	if animation_tween != null && animation_tween.is_running():
		return
	if visibility == VisibilityEnum.TRANSITION:
		return
	for card: Node in get_tree().get_nodes_in_group("game_card"):
		if card is CardTemplate and card.card_is_focused():
			card.lost_focus()

	currently_in_focus = true
	set_shader_material(_internal_focus_material)
	in_focus.emit()
	_animate_focus(focus_scale)

func lost_focus() -> void:
	currently_in_focus = false
	set_shader_material(_internal_toggle_material)
	if collider.visible:
		focus_lost.emit()

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
	return currently_in_focus

func remove_from_board() -> void:
	removal_requested = true

func removal_planed() -> void:
	removal_planned = true

func _process(_delta: float) -> void:
	if removal_planned && can_remove:
		ready_for_removal.emit()
		queue_free()
		
func input_active(is_active: bool) -> void:
	currently_ai = !is_active
	if is_active:
		unfreeze_card()
		return
	freeze_card()
