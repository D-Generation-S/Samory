extends MarginContainer

class_name  PlayerGameLabel

@export var label: RichTextLabel
@export var player_type_icon_box: TextureRect
@export var human_player_icon: Texture
@export var ai_player_icon: Texture

var active_id: int = -1
var contained_player: PlayerResource
var player_score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	label.bbcode_enabled = true
	var icon = human_player_icon
	if contained_player.is_ai():
		icon = ai_player_icon
	player_type_icon_box.texture = icon
	round_end()

func set_player(current_player: PlayerResource):
	player_score = 0
	contained_player = current_player

func player_turn(player_id: int):
	active_id = player_id
	set_player_name()

func player_scored(player_id: int, score: int):
	if contained_player.id == player_id:
		player_score = score
	set_player_name()

func build_player_name() -> String:
	var return_name = contained_player.name
	if contained_player.is_ai():
		return_name = return_name + " [AI]"
	return return_name + " (" + str(player_score) + ")"

func set_player_name():
	label.text = build_player_name()
	if contained_player.id == active_id:
		label.text = "[color=red]" + build_player_name() + "[/color]"

func round_end():
	set_player_name()
	
