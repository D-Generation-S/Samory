extends ClickableButton

@export var dynamic_neighbor_top: Control
@export var dynamic_neighbor_right: Control
@export var dynamic_neighbor_bottom: Control
@export var dynamic_neighbor_left: Control

var _initial_top_neighbor: NodePath
var _initial_right_neighbor: NodePath
var _initial_left_neighbor: NodePath
var _initial_bottom_neighbor: NodePath

func _ready() -> void:
	super()
	_initial_top_neighbor = focus_neighbor_top
	focus_neighbor_right = _initial_right_neighbor
	focus_neighbor_bottom = _initial_bottom_neighbor
	focus_neighbor_left = _initial_left_neighbor

func neighbor_shown() -> void:
	if dynamic_neighbor_top != null:
		focus_neighbor_top = dynamic_neighbor_top.get_path()
	if dynamic_neighbor_right != null:
		focus_neighbor_right = dynamic_neighbor_right.get_path()
	if dynamic_neighbor_bottom != null:
		focus_neighbor_bottom = dynamic_neighbor_bottom.get_path()
	if dynamic_neighbor_left != null:
		focus_neighbor_left = dynamic_neighbor_left.get_path()

func neighbor_hidden() -> void:
	focus_neighbor_top = _initial_top_neighbor
	focus_neighbor_right = _initial_right_neighbor
	focus_neighbor_bottom = _initial_bottom_neighbor
	focus_neighbor_left = _initial_left_neighbor
