class_name ScoreAndName extends HBoxContainer

func is_now_active():
	for child in get_children():
		if child is PlayerScoreInformation:
			child.is_now_active()

func is_now_inactive():
	for child in get_children():
		if child is PlayerScoreInformation:
			child.is_now_inactive()