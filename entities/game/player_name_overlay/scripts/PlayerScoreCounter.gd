class_name PlayerScoreCounter extends PlayerScoreInformation

@export var target_font_size: int = 30
@export var default_font_size: int = 20;
@export var transition_duration: float = 0.4;

var current_displayed_score: int = 0
var target_score: int = 0

func _ready() -> void:
	super()
	set("theme_override_font_sizes/font_size", default_font_size)

func set_new_score(new_score: int) -> void:
	target_score = new_score
	animate_score()

func animate_score() -> void:
	if current_displayed_score == target_score:
		return
	
	var animation_tween: Tween = create_tween()
	animation_tween.step_finished.connect(func(_step: int) -> void: 
		text = str(target_score)
		current_displayed_score = target_score
	)
	animation_tween.tween_property(self, "theme_override_font_sizes/font_size", target_font_size, transition_duration)
	animation_tween.tween_property(self, "theme_override_font_sizes/font_size", default_font_size, transition_duration)