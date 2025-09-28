extends Camera2D

signal touch_used()

@export_group("Zoom")
@export var zoom_per_card: float = 0.0005
@export_range(1,2) var max_zoom: float = 1.8
@export_range(0.1, 0.2) var min_zoom: float = 0.15
@export_range(0.01, 0.2) var zoom_step: float = 0.01

@export_group("Area")
@export var max_x_range: int = 7000
@export var max_y_range:int = 3500

@export_group("Dragging")
@export var drag_speed: float = 1
@export var touch_speed: float = 1.3
@export var controller_drag_speed: float = 5


var _dragging: bool = false
var _initial_drag: bool = false
var _last_mouse_pos: Vector2

var _initial_position: Vector2
var _initial_zoom: Vector2

func _ready():
	var screen_size = DisplayServer.screen_get_size()
	position = Vector2(screen_size.x / 2, screen_size.y / 2)
	process_mode = Node.PROCESS_MODE_DISABLED

func loading_done():
	process_mode = Node.PROCESS_MODE_INHERIT
	position = _initial_position
	var tween = create_tween()
	tween.tween_property(self, "zoom", _initial_zoom, 1.0)

func _input(event):
	if event is InputEventScreenDrag:
		position = position - event.relative * touch_speed
		touch_used.emit()

func _process(_delta):
	handle_camera_movement()

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
		_dragging = true
		_initial_drag = true
	if Input.is_action_just_released("drag"):
		_dragging = false
	if offset != Vector2.ZERO:
		var position_x = clamp(position.x + offset.x, -max_x_range, max_x_range)
		var position_y = clamp(position.y + offset.y, -max_y_range, max_y_range)
		position = Vector2(position_x, position_y)

		offset = Vector2.ZERO

	if _dragging:
		drag_mouse()

	drag_controller(controller_drag_vector)
	pass

func drag_mouse():
	if _initial_drag:
		_initial_drag = false
		_last_mouse_pos = get_viewport().get_mouse_position()
	
	var delta = get_viewport().get_mouse_position() - _last_mouse_pos
	offset = offset - Vector2(delta.x * drag_speed, delta.y * drag_speed)

	_last_mouse_pos = get_viewport().get_mouse_position()

func drag_controller(delta: Vector2):
	if delta == Vector2.ZERO:
		return
	offset = offset + delta * controller_drag_speed

func adjust_zoom_and_position_to_play_area(area: Rect2):
	var larger_side = max(area.size.x, area.size.y * 1.3)

	var zoom_value: float = (zoom_per_card * larger_side) * get_window().content_scale_factor
	zoom_value = clampf(zoom_value, min_zoom, max_zoom)
	zoom_value = max_zoom - zoom_value
	zoom_value = clampf(zoom_value, min_zoom, max_zoom)

	_initial_position = Vector2(area.position.x, area.position.y)

	var zoom_multipler = GlobalGameManagerAccess.get_game_manager().get_camera_zoom_adjustment()

	_initial_zoom = Vector2(zoom_value * zoom_multipler, zoom_value * zoom_multipler)