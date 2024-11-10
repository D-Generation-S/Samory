extends Camera2D

signal game_menu_requested()
signal card_movement(information: Vector2)
signal confirm_current_card()

@export_range(1,2) var max_zoom: float = 1.8
@export_range(0.1, 0.2) var min_zoom: float = 0.15
@export_range(0.01, 0.2) var zoom_step: float = 0.01
@export var max_x_range: int = 7000
@export var max_y_range:int = 3500
@export var drag_speed:float = 1
@export var controller_drag_speed:float = 5

var dragging = false
var initial_drag = false
var last_mouse_pos: Vector2
var paused = false
var can_end_round = false

var parent_node: MemoryGame

func _ready():
	parent_node = get_parent() as MemoryGame
	var screen_size = DisplayServer.screen_get_size()
	position = Vector2(screen_size.x / 2, screen_size.y / 2)

func _process(_delta):
	if paused:
		return
	var controller_drag_vector = Input.get_vector("drag_left", "drag_right", "drag_up", "drag_down")
		
	var zoom_vector = Input.get_axis("zoom_in", "zoom_out")

	if Input.is_action_just_pressed("stepped_zoom_in"):
		zoom_vector = 2
	if Input.is_action_just_pressed("stepped_zoom_out"):
		zoom_vector = -2

	zoom_vector = zoom_vector *  zoom_step
	zoom = zoom + Vector2(zoom_vector, zoom_vector)

	if Input.is_action_just_pressed("drag"):
		dragging = true
		initial_drag = true
	if Input.is_action_just_released("drag"):
		dragging = false
	if Input.is_action_just_pressed("back"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		game_menu_requested.emit()
	if Input.is_action_just_pressed("next_round") and can_end_round:
		can_end_round = false
		parent_node.end_round_now()

	var movement = Vector2.ZERO
	if Input.is_action_just_pressed("move_left"):
		movement.x = -1
	if Input.is_action_just_pressed("move_right"):
		movement.x = 1

	if Input.is_action_just_pressed("move_up"):
		movement.y = -1
	if Input.is_action_just_pressed("move_down"):
		movement.y = 1

	if Input.is_action_just_pressed("confirm"):
		confirm_current_card.emit()

	if movement != Vector2.ZERO:
		card_movement.emit(movement)
		
	var zoom_x = clampf(zoom.x, min_zoom, max_zoom)
	zoom = Vector2(zoom_x, zoom_x)

	if offset != Vector2.ZERO:
		var position_x = clamp(position.x + offset.x, -max_x_range, max_x_range)
		var position_y = clamp(position.y + offset.y, -max_y_range, max_y_range)
		position = Vector2(position_x, position_y)

		offset = Vector2.ZERO

	if dragging:
		drag_mouse()

	drag_controller(controller_drag_vector)

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
	paused = is_paused
	


func game_state_changed(game_state: int):
	match game_state:
		GameState.PREPARE_ROUND_END:
			can_end_round = true
	