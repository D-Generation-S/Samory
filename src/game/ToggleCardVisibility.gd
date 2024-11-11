extends Sprite2D

class_name ToggleCardVisibility

signal ready_for_removal()

@export_range(0.01, 0.2) var threshold_change_step: float = 0.01
@export var toggle_material: Material
@export var focus_material: Material

var threshold: float = 0
var toggle_off_now: bool = false
var toggle_on_now: bool = false
var currently_in_focus: bool = false

var collider: Area2D
var remove_if_possible: bool = false
var currently_ai: bool = false


func _ready():
	collider = get_children()[0]
	# This makes sure that each instance does get it's own shader instance
	set_shader_material(toggle_material)

func toggle_on():
	toggle_on_now = true
	toggle_off_now = false
	if currently_in_focus:
		set_shader_material(toggle_material)

func freeze_card():
	collider.visible = false
	
func unfreeze_card():
	if currently_ai:
		return
	collider.visible = true

func toggle_off():
	toggle_off_now = true
	if currently_in_focus:
		set_shader_material(toggle_material)

func is_focused():
	if toggle_off_now or toggle_on_now:
		return
	for card in get_parent().get_parent().get_children():
		if card is CardTemplate and card.card_is_focused():
			card.lost_focus()

	currently_in_focus = true
	set_shader_material(focus_material)

func lost_focus():
	currently_in_focus = false
	set_shader_material(toggle_material)

func set_shader_material(new_material: Material):
	material = new_material.duplicate()

func is_hidden() -> bool:
	return threshold <= 0

func is_fully_shown() -> bool:
	return threshold >= 1

func is_currently_in_focus() -> bool:
	return currently_in_focus

func remove_from_board():
	remove_if_possible = true

func _process(_delta):
	var changed = false
	if toggle_off_now:
		changed = true
		threshold = threshold + threshold_change_step

	if toggle_on_now && !remove_if_possible:
		changed = true
		threshold = threshold - threshold_change_step

	if threshold < 0:
		toggle_on_now = false
		threshold = 0

	if threshold > 1:
		toggle_off_now = false
		threshold = 1

	if changed:
		material.set("shader_parameter/threshold", threshold)

	if remove_if_possible && threshold >= 1:
		ready_for_removal.emit()
		queue_free()
		
func input_active(is_active: bool):
	currently_ai = !is_active
	if is_active:
		unfreeze_card()
		return
	freeze_card()