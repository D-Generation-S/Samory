extends Sprite2D

class_name ToggleCardVisibility

signal ready_for_removal()
signal fully_hidden()
signal hide_started()
signal in_focus()
signal focus_lost()

@export var animation_time: float = 0.7
@export var focus_animation_time: float = 0.2
@export var focus_scale: float = 1.03
@export var toggle_material: ShaderMaterial
@export var focus_material: ShaderMaterial

var _internal_toggle_material: ShaderMaterial
var _internal_focus_material: ShaderMaterial

var currently_in_focus: bool = false

var collider: Area2D
var removal_requested: bool = false
var can_remove: bool = false
var currently_ai: bool = false

var animation_tween: Tween = null
var _focus_tween: Tween = null

func _ready():
	collider = get_children()[0]
	visible = true
	_internal_focus_material = focus_material.duplicate_deep()
	_internal_toggle_material = toggle_material.duplicate_deep()
	# This ensures that each instance does get it's own shader instance
	set_shader_material(_internal_toggle_material)

func deck_changed(deck: MemoryDeckResource):
	if deck.card_back != null:
		texture = deck.card_back

func toggle_on():
	can_remove = false
	if is_hidden():
		return
	if animation_tween != null:
		animation_tween.kill()
	hide_started.emit()
	lost_focus()
	animation_tween = create_tween()
	animation_tween.tween_method(update_toggle_material, 1.0, 0.0, animation_time)
	animation_tween.finished.connect(func(): fully_hidden.emit())
	if currently_in_focus:
		set_shader_material(_internal_toggle_material)

func freeze_card():
	collider.visible = false
	
func unfreeze_card():
	if currently_ai:
		return
	collider.visible = true

func toggle_off():
	if animation_tween != null:
		animation_tween.kill()
	animation_tween = create_tween()
	animation_tween.tween_method(update_toggle_material, 0.0, 1.0, animation_time)
	animation_tween.finished.connect(func(): can_remove = true)
	if currently_in_focus:
		set_shader_material(_internal_toggle_material)

func update_toggle_material(progress: float):
	if material is ShaderMaterial:
		material.set_shader_parameter("threshold", progress)	

func is_focused():
	if animation_tween != null && animation_tween.is_running():
		return
	for card in get_tree().get_nodes_in_group("game_card"):
		if card is CardTemplate and card.card_is_focused():
			card.lost_focus()

	currently_in_focus = true
	set_shader_material(_internal_focus_material)
	in_focus.emit()
	_animate_focus(focus_scale)

func lost_focus():
	currently_in_focus = false
	set_shader_material(_internal_toggle_material)
	if collider.visible:
		focus_lost.emit()

	_animate_focus(1.0)

func _animate_focus(new_scale: float):
	_focus_tween = create_tween()
	_focus_tween.tween_property(self, "scale", Vector2(new_scale, new_scale), focus_animation_time)

func set_shader_material(new_material: Material):
	material = new_material

func is_hidden() -> bool:
	var card_back_visible = false
	if get_shader_threshold() <= 0:
		card_back_visible = true
	return card_back_visible

func get_shader_threshold() -> float:
	var value = -1.0
	if material is ShaderMaterial:
		value = material.get_shader_parameter("threshold")
		if value == null:
			value = -1.0
	return value

func is_fully_shown() -> bool:
	var card_back_visible = true
	if get_shader_threshold() >= 1:
		card_back_visible = false
	return !card_back_visible

func is_currently_in_focus() -> bool:
	return currently_in_focus

func remove_from_board():
	removal_requested = true

func _process(_delta):
	if removal_requested && can_remove:
		ready_for_removal.emit()
		queue_free()
		
func input_active(is_active: bool):
	currently_ai = !is_active
	if is_active:
		unfreeze_card()
		return
	freeze_card()