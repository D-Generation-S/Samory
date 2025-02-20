@tool
class_name AiPlayerSelect extends OptionButton

signal item_changed(ai: AiDifficultyResource)

@export var initial_index: int = 0:
	set(new_resource):
		print("index_set")
		initial_index = new_resource
		update_comb_box_entries()
		
		update_comb_box_entries()
@export var ai_options: Array[AiDifficultyResource] = []:
	set(new_resource):
		print("options_set")
		ai_options = new_resource
		update_comb_box_entries()

func update_comb_box_entries():
	print("update")
	clear()
	var counter = 0
	for option in ai_options:
		add_item(tr(option.name), counter)
		counter = counter + 1

	selected = initial_index


# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint():
		return
	item_selected.connect(selection_changed)
	item_changed.emit(ai_options[initial_index])

func selection_changed(index: int):
	if Engine.is_editor_hint():
		return
	var item = ai_options[index]
	item_changed.emit(item)
