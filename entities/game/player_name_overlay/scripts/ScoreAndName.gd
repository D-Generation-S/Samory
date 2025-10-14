class_name ScoreAndName extends HBoxContainer

func is_now_active() -> void:
	for child: Node in get_children():
		if child is PlayerScoreInformation:
			child.is_now_active()

func is_now_inactive() -> void:
	for child: Node in get_children():
		if child is PlayerScoreInformation:
			child.is_now_inactive()