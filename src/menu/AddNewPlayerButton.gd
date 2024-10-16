extends ClickableButton

signal player_adding()
signal player_added()
signal player_removed()

@export var root_node: GameLobby
@export var player_node: VBoxContainer
@export var player_template: PackedScene
@export var player_card_template: PackedScene

func _pressed():
	super()
	var new_player_node = player_template.instantiate() as NewPlayer
	root_node.add_child(new_player_node)
	player_adding.emit()

	new_player_node.new_player_dialog_closed.connect(root_node.enable_all_buttons)
	new_player_node.new_player_dialog_closed.connect(dialog_was_closed)
	new_player_node.new_player_added.connect(player_was_added)
	

func player_was_added(new_player: PlayerResource):
	var player_card = player_card_template.instantiate() as PlayerCard
	player_card.player_card = new_player
	player_node.add_child(player_card)
	player_card.getting_deleted.connect(player_was_removed)
	player_added.emit()
	dialog_was_closed()

func dialog_was_closed():
	grab_focus()

func player_was_removed():
	player_removed.emit();

func disable_button():
	disabled = true

func enable_button():
	disabled = false
