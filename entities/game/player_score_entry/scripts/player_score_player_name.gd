extends Label

func player_did_win(player_color: ColorResource) -> void:
	set("theme_override_colors/font_color",player_color.get_color())
