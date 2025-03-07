extends HSplitContainer

@export var default_split_size: int = -300;
@export var mobile_split_size: int = -50;

# Called when the node enters the scene tree for the first time.
func _ready():
	split_offset = default_split_size
	if is_mobile():
		split_offset = mobile_split_size

func is_mobile() -> bool:
	return OS.has_feature("web_android") or OS.has_feature("web_ios")