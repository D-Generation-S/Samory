class_name CardInteractionField extends Node2D

signal mouse_enter(grid: Vector2i)
signal mouse_left(grid: Vector2i)
signal clicked(grid: Vector2i)

@export var default_texture_size: Vector2 = Vector2(499, 550)
@export var collider_template: PackedScene = null
@export var additional_offset: Vector2i = Vector2i(0, 25)

var _separation: int = 0
var _offset: Vector2i = Vector2i.ZERO
var _card_size: Vector2

var _is_ai_player: bool = false

func set_board_information(deck_to_use: MemoryDeckResource, card_separation: int, field_offset: Vector2i) -> void:
	var back_image: Texture2D = deck_to_use.get_back_image()
	_card_size = default_texture_size
	if back_image != null:
		_card_size = deck_to_use.get_back_image().get_size()
	_separation = card_separation
	_offset = field_offset

func build_field(cards_on_x: int, cards_on_y: int) -> void:
	for x: int in cards_on_x:
		for y: int in cards_on_y:
			var x_addition: int = _separation * x
			x_addition += int(_card_size.x) * x
			var y_addition: int = _separation * y
			y_addition += int(_card_size.y) * y
			var template: CardCollider = collider_template.instantiate()
			template.set_size(_card_size)
			template.position = _offset + additional_offset + Vector2i(x_addition, y_addition)
			template.set_grid_coordinate(Vector2i(x, y))
			_connect_card_interaction(template)

			add_child(template)
			template.disable_collider()

func card_was_added(card: CardTemplate) -> void:
	card.remove_requested.connect(remove_card.bind(card.grid_position))

func remove_card(grid_position: Vector2i) -> void:
	for child: CardCollider in get_children():
		if child.get_grid_coordinate() == grid_position:
			child.queue_free()

func player_changed(current_player: PlayerResource) -> void:
	_is_ai_player = current_player.is_ai()

func game_state_changed(new_state: GameEnum.State) -> void:
	var _new_collider_enabled_state: bool = false
	if new_state == GameEnum.State.TURN_START and not _is_ai_player:
		_new_collider_enabled_state = true
		
	if new_state == GameEnum.State.TURN_FREEZE:
		_new_collider_enabled_state = false

	_change_interaction_state(_new_collider_enabled_state)

func _change_interaction_state(new_state: bool) -> void:
	for child: CardCollider in get_children():
		if new_state:
			child.enable_collider()
		else:
			child.disable_collider()

func _connect_card_interaction(collider: CardCollider) -> void:
	collider.mouse_enter.connect(func(data: Vector2i) -> void: mouse_enter.emit(data))
	collider.mouse_left.connect(func(data: Vector2i) -> void: mouse_left.emit(data))
	collider.clicked.connect(func(data: Vector2i) -> void: clicked.emit(data))
