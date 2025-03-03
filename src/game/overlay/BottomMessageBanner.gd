class_name BottomMessageBanner extends PopupWindow

var timer: Timer = null
var should_close_automatically: bool = false

var label_text: String = ""
var banner_close_action: Callable = Callable()

func _init():
	timer = Timer.new()
	timer.autostart = false

func initialize_popup(message: String, time_until_close_in_seconds: float, should_auto_close: bool = true, close_action: Callable = Callable()):
	timer.wait_time = time_until_close_in_seconds
	should_close_automatically = should_auto_close
	banner_close_action = close_action

	var translated_message = tr(message)
	translated_message = translated_message.replace("%time%", str(time_until_close_in_seconds))
	label_text = translated_message

func timer_timeout():
	close_popup()

func popup_active():
	super()
	if was_activated and should_close_automatically:
		timer.paused = false

	var label = get_node("%MessageLabel") as Label
	label.text = label_text

	if should_close_automatically:
		add_child(timer)
		timer.start()
		timer.timeout.connect(timer_timeout)

	was_activated = true

func close_popup():
	popup_closed.emit()
	banner_close_action.call()
	queue_free()

func popup_paused():
	timer.paused = true