extends ClickableButton

@export var player_list: VBoxContainer
@export var deck_manager: DisplayDecksInGrid

var deck_valid: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	disabled = true

func _pressed():
	super()
	validate()

	if disabled == true:
		return
		
	var deck = deck_manager.current_deck
	var players: Array[PlayerResource] = []
	for player in player_list.get_children():
		if player is PlayerCard and player.player_card != null:
			players.append(player.player_card)

	GlobalGameManagerAccess.get_game_manager().play_game(players, deck)
	

func validate_players() -> bool:
	var valid_players: int = 0
	for player in player_list.get_children():
		if player is PlayerCard and player.player_card != null and !player.is_getting_deleted():
			valid_players = valid_players + 1

	return valid_players >= 2

func deck_changed(deck: MemoryDeckResource):
	deck_valid = deck != null
	validate()

func deck_unselected():
	deck_valid = false
	validate()

func validate():
	disabled = true
	if validate_players() and deck_valid:
		disabled = false
