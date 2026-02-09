extends TextureRect

var _should_be_shown: bool = false

func _ready() -> void:
	visible = false

func player_did_win(_color: ColorResource) -> void:
	_should_be_shown = true

func scoring_is_done() -> void:
	if not _should_be_shown:
		return

	visible = true