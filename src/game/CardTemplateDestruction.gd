extends CanvasGroup

signal ready_for_destruction()

@export var possible_effects: Array[Material] = [];
@export var progress_per_tick: float = 0.2;

var root_node: CardTemplate = null;
var progress: float  = 0;
var destroy_now: bool = false;
	 

# Called when the node enters the scene tree for the first time.
func _ready():
	root_node = get_parent();

func _process(delta):
	if !destroy_now:
		return
	
	progress = progress + progress_per_tick * delta
	progress = clampf(progress, 0.0 , 1.0);
	material.set_shader_parameter("progress", progress);

	if progress == 1:
		ready_for_destruction.emit()

func animate_destruction():
	print("kill me!")
	ready_for_destruction.emit()
