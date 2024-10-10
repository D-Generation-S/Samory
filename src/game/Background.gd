extends Node2D

@export var number_x: int = 20
@export var number_y: int = 16
@export var background_texture: Texture2D
@export var camera_node: Camera2D

var background_pool_node: Node2D
var screen_width: float
var screen_height: float

# Called when the node enters the scene tree for the first time.
func _ready():
	background_pool_node = Node2D.new()
	background_pool_node.global_position = camera_node.global_position
	background_pool_node.name = "background_pool"
	add_child(background_pool_node)

	fill_screen()

func fill_screen():
	var x_start_pos = number_x / 2 * background_texture.get_width()
	var y_start_pos = number_y / 2 * background_texture.get_width()
	var start_pos = Vector2(-x_start_pos, -y_start_pos)
	for x in number_x:
		for y in number_y:
			var x_pos = start_pos.x + background_texture.get_width() * x
			var y_pos = start_pos.y + background_texture.get_height() * y
			var new_position = Vector2(x_pos, y_pos)

			var node = create_new_sprite()
			background_pool_node.add_child(node)
			node.global_position = new_position
			node.name = str(x) + "/" + str(y)
			node.visible = true

func create_new_sprite() -> Sprite2D:
	var sprite = Sprite2D.new()
	sprite.texture = background_texture
	sprite.position = Vector2.ZERO

	return sprite