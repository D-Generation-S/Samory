class_name SingleFold extends FoldableContainer

## Check if the auto add group should be scanned on ready, each entry will be connected to only allow a single foldable open
@export var auto_add_components: bool = false
## The group to search elements in, those are added to auto fold
@export var auto_add_group: String = ""

func _ready():
	if not auto_add_components:
		return

	for item in get_tree().get_nodes_in_group(auto_add_group):
		if item is SingleFold:
			if self.get_instance_id() == item.get_instance_id():
				continue
			folding_changed.connect(item.other_was_folded)
			

func other_was_folded(new_state: bool):
	if new_state:
		return

	folded = true