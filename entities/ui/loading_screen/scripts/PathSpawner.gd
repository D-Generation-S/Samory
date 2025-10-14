extends PathFollow2D

@export var spawn_interval_seconds: float = 0.25
@export var lowest_fall_line: float = 2000
@export var pre_generated_cards: int = 30
@export var spawn_template: PackedScene
@export var spawn_target: Node2D

var current_interval: float = 0
var cards: Array[RigidBody2D] = []

func _ready() -> void:
	current_interval = spawn_interval_seconds
	for i: int in pre_generated_cards:
		cards.append(spawn_template.instantiate() as RigidBody2D)

func _process(delta: float) -> void:
	current_interval = current_interval + delta
	if current_interval < spawn_interval_seconds:
		return		
	current_interval = spawn_interval_seconds - current_interval
	collect_old_cards()
	var new_ratio: float = randf()
	progress_ratio = new_ratio
	var node: RigidBody2D = get_card()
	node.global_position = global_position
	node.linear_velocity = Vector2.ZERO
	node.freeze = false

	if node.get_parent() == null:
		spawn_target.add_child(node)

func collect_old_cards() -> void:
	for child: FallingCard in spawn_target.get_children():
		if child.global_position.y > lowest_fall_line:
			child.freeze = true
			child.reset_card()
			cards.append(child)

func get_card() -> RigidBody2D:
	var card: RigidBody2D = cards.pop_back() as RigidBody2D
	if card == null:
		card = spawn_template.instantiate() as RigidBody2D
	return card
