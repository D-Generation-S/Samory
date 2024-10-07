extends Camera2D

@export_range(0.01, 0.2) var zoom_step: float = 0.03
@export var drag_speed = 1

var dragging = false
var initial_drag = false
var last_mouse_pos: Vector2

var parent_node: Node2D

func _ready():
	parent_node = get_parent() as Node2D

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


	if dragging:
		drag_mouse()

func drag_mouse():
	if initial_drag:
		initial_drag = false
		last_mouse_pos = get_viewport().get_mouse_position()
	
	var delta = get_viewport().get_mouse_position() - last_mouse_pos
	offset = offset - Vector2(delta.x * drag_speed, delta.y * drag_speed)

	last_mouse_pos = get_viewport().get_mouse_position()
