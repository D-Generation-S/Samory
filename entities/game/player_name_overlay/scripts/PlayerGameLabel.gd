extends MarginContainer

class_name PlayerGameLabel

signal player_is_active()
signal player_is_inactive()
signal player_score_changed(new_value: int)
signal player_name_changed(new_player_name: String)

@export var player_type_icon_box: TextureRect
@export var human_player_icon: Texture
@export var ai_player_icon: Texture
@export var player_round_color: ColorResource

var active_id: int = -1
var contained_player: PlayerResource

func _ready() -> void:
	var icon: Texture = human_player_icon
	if contained_player.is_ai():
		icon = ai_player_icon
	player_type_icon_box.texture = icon
	round_end()

func set_player(current_player: PlayerResource) -> void:
	contained_player = current_player

func player_turn(player_id: int) -> void:
	active_id = player_id
	set_player_name()

func player_scored(player_id: int, score: int) -> void:
	if contained_player.id == player_id:
		player_score_changed.emit(score)
	set_player_name()

func set_player_name() -> void:
	player_name_changed.emit(contained_player.get_display_name())
	if contained_player.id == active_id:
		player_is_active.emit()
	else:
		player_is_inactive.emit()

func round_end() -> void:
	set_player_name()
	
