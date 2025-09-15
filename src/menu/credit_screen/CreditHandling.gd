extends RichTextLabel

@export_range(0.1, 1000, 0.1, "suffix:ms") var timer_tick: float = 200
@export var scroll_speed: int = 5
@export var scrolling_active: bool = true

var timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	if scrolling_active:
		position.y = DisplayServer.window_get_size().y
	setup_timer_for_scroll()

func setup_timer_for_scroll():
	if !scrolling_active:
		return
	timer = Timer.new()
	timer.wait_time = timer_tick / 1000;
	timer.timeout.connect(timer_timeout)
	add_child(timer)
	timer.start()
	
func timer_timeout():
	position.y = position.y - scroll_speed
