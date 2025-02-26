extends RichTextLabel

@export_range(0.1, 1000, 0.1, "suffix:ms") var timer_tick: float = 200
@export var scroll_speed: int = 5
@export var scrolling_active: bool = true

var timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	load_credits()
	setup_timer_for_scroll()

func load_credits():
	var data_source = "res://assets/text/"
	var specific_file = data_source + "credits." + TranslationServer.get_locale() + ".txt"
	var fallback = data_source + "credits.txt"

	var data = try_and_load_credits(specific_file)
	if data == "":
		data = try_and_load_credits(fallback)

	text = data
	if scrolling_active:
		position.y = DisplayServer.window_get_size().y
	
	

func try_and_load_credits(path: String) -> String:
	var text_file = FileAccess.open(path, FileAccess.READ)
	if text_file == null:
		printerr("Failed to open credits file \" "+ path +"\"")
		return ""
	return text_file.get_as_text()

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
