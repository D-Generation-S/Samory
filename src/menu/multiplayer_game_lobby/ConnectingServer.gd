extends PanelContainer

signal text_updated(new_text: String)

@export var text_template: TextTranslation = null
## The seconds until a new dot appears
@export var dot_interval: float = 0.4
@export var max_dots: int = 3

var _timer: Timer = null
var _current_dot_count: int = 0

func _ready() -> void:
	if text_template == null:
		printerr("Missing text template, removing")
		got_connected()
	await get_tree().physics_frame
	if multiplayer.is_server():
		got_connected()
		return
	_timer = Timer.new()
	_timer.autostart = true
	_timer.one_shot = false
	_timer.wait_time = dot_interval
	_timer.timeout.connect(_timer_ticked)
	add_child(_timer)

func _timer_ticked() -> void:
	_current_dot_count = _current_dot_count + 1
	if _current_dot_count > max_dots:
		_current_dot_count = 0
	
	var dots: String = " "
	for i: int in _current_dot_count:
		dots = dots + "."
	
	text_updated.emit(tr(text_template.key) + dots)

func got_connected() -> void:
	queue_free()