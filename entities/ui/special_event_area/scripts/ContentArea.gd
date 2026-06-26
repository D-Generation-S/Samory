class_name SpecialEventContentArea extends MarginContainer

@export var event_box_template: PackedScene = preload("res://entities/ui/special_event_area/scenes/SpecialEventBox.tscn")

func add_event(new_event: SpecialEvent) -> void:
	var box: SpecialEventBox = event_box_template.instantiate() as SpecialEventBox
	box.set_event(new_event)
	box.visible = get_child_count() == 0
	add_child(box)

func show_next() -> void:
	var index: int = get_children().find_custom(func (child: SpecialEventBox) -> bool: return child.visible)
	var current_active: SpecialEventBox = get_children()[index] as SpecialEventBox
	index += 1
	if index >= get_child_count():
		index = 0
	var next_active: SpecialEventBox = get_children()[index] as SpecialEventBox

	current_active.visible = false
	next_active.visible = true
	
func show_previous() -> void:
	var index: int = get_children().find_custom(func (child: SpecialEventBox) -> bool: return child.visible)
	var current_active: SpecialEventBox = get_children()[index] as SpecialEventBox
	index -= 1
	if index < 0:
		index = get_child_count() - 1
	var next_active: SpecialEventBox = get_children()[index] as SpecialEventBox
	current_active.visible = false
	next_active.visible = true
	