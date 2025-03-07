extends Camera2D

signal game_menu_requested()
signal card_movement(information: Vector2)
signal confirm_current_card()

@export var zoom_per_card: float = 0.0005
@export_range(1,2) var max_zoom: float = 1.8
@export_range(0.1, 0.2) var min_zoom: float = 0.15
@export_range(0.01, 0.2) var zoom_step: float = 0.01
@export var max_x_range: int = 7000
@export var max_y_range:int = 3500
@export var drag_speed: float = 1
@export var touch_speed: float = 1.3
@export var controller_drag_speed: float = 5
@export var frames_to_skip_after_pause: int = 2


var dragging: bool = false
var initial_drag: bool = false
var last_mouse_pos: Vector2
var resumed_from_pause = false
var skipped_frames = 0
var can_end_round: bool = false
var current_ai_player: bool = false

var parent_node: MemoryGame
var initial_position: Vector2
var initial_zoom: Vector2

func _ready():
	parent_node = get_parent() as MemoryGame
	var screen_size = DisplayServer.screen_get_size()
	position = Vector2(screen_size.x / 2, screen_size.y / 2)
	process_mode = Node.PROCESS_MODE_DISABLED

func loading_done():
	zoom = initial_zoom
	position = initial_position
	process_mode = Node.PROCESS_MODE_INHERIT

func _input(event):
	if event is InputEventScreenDrag:
		position = position - event.relative * touch_speed

func _process(_delta):
	if resumed_from_pause:
		if skipped_frames > frames_to_skip_after_pause:
			resumed_from_pause = false
			skipped_frames = 0
		skipped_frames += 1
		return
	handle_special_player_actions()
	handle_camera_movement()
	handle_player_input_actions()

func handle_camera_movement():
	var zoom_vector = Input.get_axis("zoom_in", "zoom_out")

	if Input.is_action_just_pressed("stepped_zoom_in"):
		zoom_vector = 2
	if Input.is_action_just_pressed("stepped_zoom_out"):
		zoom_vector = -2

	zoom_vector = zoom_vector *  zoom_step
	zoom = zoom + Vector2(zoom_vector, zoom_vector)
	
	var zoom_x = clampf(zoom.x, min_zoom, max_zoom)
	zoom = Vector2(zoom_x, zoom_x)
	
	var controller_drag_vector = Input.get_vector("drag_left", "drag_right", "drag_up", "drag_down")
	if Input.is_action_just_pressed("drag"):
		dragging = true
		initial_drag = true
	if Input.is_action_just_released("drag"):
		dragging = false
	if offset != Vector2.ZERO:
		var position_x = clamp(position.x + offset.x, -max_x_range, max_x_range)
		var position_y = clamp(position.y + offset.y, -max_y_range, max_y_range)
		position = Vector2(position_x, position_y)

		offset = Vector2.ZERO

	if dragging:
		drag_mouse()

	drag_controller(controller_drag_vector)
	pass

func handle_player_input_actions():
	if current_ai_player:
		return
	var movement = Vector2.ZERO
	if Input.is_action_just_pressed("move_left"):
		movement.x = -1
	if Input.is_action_just_pressed("move_right"):
		movement.x = 1

	if Input.is_action_just_pressed("move_up"):
		movement.y = -1
	if Input.is_action_just_pressed("move_down"):
		movement.y = 1

	if Input.is_action_just_pressed("confirm") and !current_ai_player:
		confirm_current_card.emit()

	if movement != Vector2.ZERO:
		card_movement.emit(movement)

func handle_special_player_actions():
	if Input.is_action_just_pressed("back"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		game_menu_requested.emit()
	if Input.is_action_just_pressed("next_round") and can_end_round:
		can_end_round = false
		parent_node.end_round_now()

func drag_mouse():
	if initial_drag:
		initial_drag = false
		last_mouse_pos = get_viewport().get_mouse_position()
	
	var delta = get_viewport().get_mouse_position() - last_mouse_pos
	offset = offset - Vector2(delta.x * drag_speed, delta.y * drag_speed)

	last_mouse_pos = get_viewport().get_mouse_position()

func drag_controller(delta: Vector2):
	if delta == Vector2.ZERO:
		return
	offset = offset + delta * controller_drag_speed

func game_paused(is_paused: bool):
	resumed_from_pause = !is_paused

func game_state_changed(game_state: int):
	match game_state:
		GameState.PREPARE_ROUND_END:
			can_end_round = true
		GameState.ROUND_START:
			can_end_round = false

func player_changed(current_player:PlayerResource):
	current_ai_player = current_player.is_ai()

func adjust_zoom_and_position_to_play_area(cards_on_x: int, cards_on_y: int):
	var card_template = parent_node.card_template
	if card_template == null:
		return
	var card_instance = card_template.instantiate()
	var card_height = card_instance.get_height() + parent_node.separation
	var card_width = card_instance.get_width() + parent_node.separation

	var field_width = card_width * cards_on_x
	var field_height = card_height * cards_on_y

	var center_x = field_width / 2
	var center_y = field_height / 2

	var larger_side = max(field_width, field_height * 1.3)

	var zoom_value: float = (zoom_per_card * larger_side) * get_window().content_scale_factor
	zoom_value = clampf(zoom_value, min_zoom, max_zoom)
	zoom_value = max_zoom - zoom_value
	zoom_value = clampf(zoom_value, min_zoom, max_zoom)

	initial_position = Vector2(center_x, center_y)
	initial_zoom = Vector2(zoom_value, zoom_value)