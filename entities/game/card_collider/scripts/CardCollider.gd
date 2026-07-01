class_name CardCollider extends Node2D

signal set_shape(shape: RectangleShape2D)
signal mouse_enter(grid: Vector2i)
signal mouse_left(grid: Vector2i)
signal clicked(grid: Vector2i, card: MemoryCardResource)

var _grid_coordinate: Vector2i = Vector2i.ZERO
var _shape: CollisionShape2D = null

var _mouse_inside: bool = false
var _active_state: bool = false
var _card_data: MemoryCardResource = null

func _ready() -> void:
	_shape = get_node("%CollisionShape")

func set_data(data: MemoryCardResource) -> void:
	
	_card_data = data

func get_card_id() -> int:
	return _card_data.id

func set_size(size: Vector2) -> void:
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = size

	set_shape.emit(shape)

func set_grid_coordinate(grid_data: Vector2i) -> void:
	_grid_coordinate = grid_data

func get_grid_coordinate() -> Vector2i:
	return _grid_coordinate

func enable_collider() -> void:
	_shape.disabled = false

func disable_collider() -> void:
	_shape.disabled = true

func is_clicked() -> void:
	_active_state = false

func reset() -> void:
	_active_state = true

func is_active() -> bool:
	return _active_state

func mouse_entered() -> void:
	mouse_enter.emit(_grid_coordinate)
	_mouse_inside = true

func mouse_has_left() -> void:
	mouse_left.emit(_grid_coordinate)
	_mouse_inside = false

func input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not _mouse_inside or not _active_state:
		return
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			activate()

func activate() -> void:
	disable_collider()
	is_clicked()
	clicked.emit(_grid_coordinate, _card_data)