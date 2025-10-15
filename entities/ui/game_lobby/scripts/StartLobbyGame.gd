extends ClickableButton

@export var player_list: VBoxContainer
@export var deck_manager: DisplayDecksInGrid

var deck_valid: bool = false
var current_deck: MemoryDeckResource = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	disabled = true

func _pressed() -> void:
	validate()

	if disabled == true:
		return
		
	var deck: MemoryDeckResource = current_deck
	var players: Array[PlayerResource] = []
	for player: PlayerCard in player_list.get_children():
		if player.player_card != null:
			players.append(player.player_card)

	GlobalGameManagerAccess.get_game_manager().play_game_with_position(players, deck, get_global_center_position())
	

func validate_players() -> bool:
	var valid_players: int = 0
	var human_present: bool = false
	for player: PlayerCard in player_list.get_children().filter(func(node: Node) -> bool: return node is PlayerCard):
		if player.player_card != null and !player.is_getting_deleted():
			if !player.player_card.is_ai():
				human_present = true
			valid_players = valid_players + 1

	return valid_players >= 2 && human_present

func deck_changed(deck: MemoryDeckResource) -> void:
	current_deck = deck;
	deck_valid = current_deck != null

	validate()

func deck_unselected() -> void:
	deck_valid = false
	validate()

func validate() -> void:
	disabled = true
	if validate_players() and deck_valid:
		disabled = false

func toggle_button(on: bool) -> void:
	super(on)
	validate()
