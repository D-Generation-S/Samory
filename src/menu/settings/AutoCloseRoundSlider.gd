extends HBoxContainer

@export_range(1, 2, 1) var set_min_value: float = 1
@export_range(2, 5, 1) var set_max_value: float = 5
@export var slider: HSlider
@export var label: Label

var initial_text_template: String = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	if slider == null:
		printerr("No slider set")
		queue_free()
		return
	label.auto_translate_mode = Label.AUTO_TRANSLATE_MODE_DISABLED
	initial_text_template = label.text
	

func settings_loaded(settings: SettingsResource):
	slider.min_value = set_min_value
	slider.max_value = set_max_value
	slider.value = settings.close_round_after_seconds
	set_translated_text(slider.value)
	

func set_translated_text(value: float):
	var translated_text = tr(initial_text_template)
	translated_text = translated_text.replace("%time%", str(slider.value))
	label.text = translated_text

func toggle_visibility(new_state: bool):
	visible = new_state

func slider_changed(value: float):
	set_translated_text(value)

func language_changed(_language_code: String):
	set_translated_text(slider.value)
