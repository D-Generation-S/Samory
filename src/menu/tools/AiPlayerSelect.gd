@tool
class_name AiPlayerSelect extends OptionButton

signal item_changed(ai: AiDifficultyResource)

@export var initial_index: int = 0:
	set(new_resource):
		initial_index = new_resource
		update_comb_box_entries()
		
		update_comb_box_entries()
@export var ai_options: Array[AiDifficultyResource] = []:
	set(new_resource):
		ai_options = new_resource
		update_comb_box_entries()

func update_comb_box_entries() -> void:
	clear()
	var counter: int = 0
	for option: AiDifficultyResource in ai_options:
		add_item(option.name, counter)
		counter = counter + 1

	selected = initial_index

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	grab_focus()
	item_selected.connect(selection_changed)
	item_changed.emit(ai_options[initial_index])

func selection_changed(index: int) -> void:
	if Engine.is_editor_hint():
		return
	var item: AiDifficultyResource = ai_options[index]
	item_changed.emit(item)
