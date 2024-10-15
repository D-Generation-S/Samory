extends PathFollow2D

@export var spawn_interval_seconds: float = 0.25
@export var lowest_fall_line: float = 2000
@export var pre_generated_cards: int = 30
@export var spawn_template: PackedScene
@export var spawn_target: Node2D

var current_interval: float = 0
var cards: Array[RigidBody2D] = []

func _ready():
	current_interval = spawn_interval_seconds
	for i in range(pre_generated_cards):
		cards.append(spawn_template.instantiate() as RigidBody2D)
	

func _process(delta):
	current_interval = current_interval + delta
	if current_interval < spawn_interval_seconds:
		return		
	current_interval = spawn_interval_seconds - current_interval
	collect_old_cards()
	var new_ratio = randf()
	progress_ratio = new_ratio
	var node = get_card()
	node.global_position = global_position
	node.linear_velocity = Vector2.ZERO
	node.freeze = false

	if node.get_parent() == null:
		spawn_target.add_child(node)

func collect_old_cards():
	for child in spawn_target.get_children():
		if child is RigidBody2D and child.global_position.y > lowest_fall_line:
			child.freeze = true
			cards.append(child)

func get_card() -> RigidBody2D:
	var card = cards.pop_back()
	if card == null:
		print("Generate card")
		card = spawn_template.instantiate() as RigidBody2D
	return card
