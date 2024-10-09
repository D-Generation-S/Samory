extends Sprite2D

@export_range(0.01, 0.2) var threshold_change_step: float = 0.01
@export var toggle_material: Material
@export var focus_material: Material

var threshold = 0
var toggle_off_now = false
var toggle_on_now = false
var currently_in_focus = false

var collider: Area2D

func toggle_on():
	toggle_on_now = true
	toggle_off_now = false
	if currently_in_focus:
		set_shader_material(toggle_material)

func freeze_card():
	collider.visible = false;
	
func unfreeze_card():
	collider.visible = true;

func toggle_off():
	toggle_off_now = true
	if currently_in_focus:
		set_shader_material(toggle_material)

func is_focused():
	if toggle_off_now or toggle_on_now:
		return
	currently_in_focus = true
	set_shader_material(focus_material)

func lost_focus():
	currently_in_focus = false
	set_shader_material(toggle_material)

func set_shader_material(new_material: Material):
	material = new_material.duplicate()

func _ready():
	collider = get_children()[0]
	# This makes sure that each instance does get it's own shader instance
	set_shader_material(toggle_material)

func _process(_delta):
	var changed = false
	if toggle_off_now:
		changed = true
		threshold = threshold + threshold_change_step

	if toggle_on_now:
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