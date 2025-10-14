class_name BottomMessageBanner extends PopupWindow

signal text_changed(new_text: String)

var timer: Timer = null
var should_close_automatically: bool = false

var label_text: String = ""
var banner_close_action: Callable = Callable()

var _internal_time: float = 0
var _translation_template: TextTranslation

func _init() -> void:
	timer = Timer.new()
	timer.one_shot = true
	timer.autostart = false

func initialize_popup(message: TextTranslation, time_until_close_in_seconds: float, should_auto_close: bool = true, close_action: Callable = Callable()) -> void:
	_internal_time = time_until_close_in_seconds
	_translation_template = message

	timer.wait_time = 1

	should_close_automatically = should_auto_close
	banner_close_action = close_action

func update_text() -> void:
	var translated_message: String = tr(_translation_template.key)
	if _translation_template.plural.length() > 0:
		translated_message = tr_n(_translation_template.key, _translation_template.plural, ceil(_internal_time)) % _internal_time
	text_changed.emit(translated_message)

func timer_timeout() -> void:
	if !visible:
		return

	_internal_time = _internal_time - 1
	if _internal_time > 0:
		update_text()
		timer.start()
		return

	timer.stop()
	close_popup()

func popup_active() -> void:
	super()
	if was_activated and should_close_automatically:
		timer.paused = false
	update_text()

	if should_close_automatically:
		add_child(timer)
		timer.start()
		timer.timeout.connect(timer_timeout)

	was_activated = true

func close_popup() -> void:
	popup_closed.emit()
	banner_close_action.call()
	visible = false
	timer.stop()
	queue_free()

func popup_paused() -> void:
	timer.paused = true