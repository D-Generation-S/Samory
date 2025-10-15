class_name FallingCard extends RigidBody2D

signal dissolve(click_position: Vector2)
signal reset()

@export var active: bool = true

func _ready() -> void:
	input_pickable = true
	if !active:
		process_mode = Node.PROCESS_MODE_DISABLED

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		dissolve.emit(to_local(get_global_mouse_position()))

func reset_card() -> void:
	reset.emit()

func dissolve_card() -> void:
	dissolve.emit()