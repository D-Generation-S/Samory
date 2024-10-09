extends Camera2D

@export_range(1,2) var max_zoom: float = 1.8
@export_range(0.1, 0.2) var min_zoom: float = 0.15
@export_range(0.01, 0.2) var zoom_step: float = 0.03
@export var max_x_range: int = 7000
@export var max_y_range:int = 3500
@export var drag_speed = 1

var dragging = false
var initial_drag = false
var last_mouse_pos: Vector2

var parent_node: Node2D

func _ready():
	parent_node = get_parent() as Node2D
	var screen_size = DisplayServer.screen_get_size()
	position = Vector2(screen_size.x / 2, screen_size.y / 2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("zoom_in"):
		zoom = zoom + Vector2(zoom_step, zoom_step)
	if Input.is_action_just_pressed("zoom_out"):
		zoom = zoom - Vector2(zoom_step, zoom_step)
	if Input.is_action_just_pressed("drag"):
		dragging = true
		initial_drag = true
	if Input.is_action_just_released("drag"):
		dragging = false
	if Input.is_action_just_pressed("next_round") and parent_node.get_current_game_phase() == GameState.ROUND_FREEZE:
		print("Trigger next round")
		parent_node.end_round_now()
		
	var zoom_x = clampf(zoom.x, min_zoom, max_zoom)
	zoom = Vector2(zoom_x, zoom_x)

	if offset != Vector2.ZERO:
		var position_x = clamp(position.x + offset.x, -max_x_range, max_x_range)
		var position_y = clamp(position.y + offset.y, -max_y_range, max_y_range)
		position = Vector2(position_x, position_y)

		offset = Vector2.ZERO

	if dragging:
		drag_mouse()
		

func drag_mouse():
	if initial_drag:
		initial_drag = false
		last_mouse_pos = get_viewport().get_mouse_position()
	
	var delta = get_viewport().get_mouse_position() - last_mouse_pos
	offset = offset - Vector2(delta.x * drag_speed, delta.y * drag_speed)

	last_mouse_pos = get_viewport().get_mouse_position()
