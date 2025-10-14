extends ClickableButton

signal player_adding()
signal dialog_closed()
signal player_added(new_player: PlayerResource)
signal show_special_control(new_control: Control)

@export var root_node: GameLobby
@export var player_node: VBoxContainer
@export var player_template: PackedScene
@export var player_card_template: PackedScene

func _pressed() -> void:
	var new_player_node: NewPlayer = player_template.instantiate() as NewPlayer

	player_adding.emit()

	new_player_node.new_player_dialog_closed.connect(root_node.enable_all_buttons)
	new_player_node.new_player_dialog_closed.connect(dialog_was_closed)
	new_player_node.new_player_added.connect(player_was_added)

	show_special_control.emit(new_player_node)

func player_was_added(new_player: PlayerResource) -> void:
	dialog_closed.emit()
	player_added.emit(new_player)

func dialog_was_closed() -> void:
	dialog_closed.emit()
	grab_focus()
