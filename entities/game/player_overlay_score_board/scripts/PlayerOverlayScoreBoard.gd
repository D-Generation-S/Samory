class_name PlayerOverlayScoreBoard extends Control

signal _card_animation_done()

@export_group("Visuals")
@export var fallback_texture: Texture2D
@export var max_size: float = 40
@export var rotation_limit_degree: float = 8
@export var min_separation: float = 5
@export var max_separation: float = 12
@export var max_visualized_cards: int = 5
@export var inactive_visibility: float = 0.7

@export_group("Label")
@export var active_color: ColorResource
@export var inactive_color: ColorResource

@export_group("Animation")
## Animation time for the first card
@export var animation_time: float = 0.5

## Additional animation time for the second card
@export var animation_time_difference: float = 0.0

var _current_spawn_position_x: float = 0
var _current_card_count: int = 0
var _texture: Texture2D = null
var _card_templates: Array[TextureRect] = []
var _is_active: bool = true

var _label: PlayerScoreCounter = null

func _ready() -> void:
	_label = PlayerScoreCounter.new()
	_label.inactive_color = inactive_color
	_label.active_color = active_color
	_label.custom_minimum_size = Vector2(max_size, max_size)
	_label.custom_maximum_size = Vector2(max_size, max_size)
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_label.z_index = 2
	add_child(_label)
	
func player_is_active() -> void:
	_label.is_now_active()
	_is_active = true
	change_visibility(_is_active)

func player_is_inactive() -> void:
	_label.is_now_inactive()
	_is_active = false
	change_visibility(_is_active)

func change_visibility(visible: bool) -> void:
	var target: float = inactive_visibility
	if visible:
		target = 1.0
	for card: TextureRect in _card_templates:	
		var tween: Tween = create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(card, "modulate", Color(1.0, 1.0, 1.0, target), animation_time)

func _get_texture() -> Texture2D:
	if _texture != null:
		return _texture
	return fallback_texture

func set_texture(new_texture: Texture2D) -> void:
	_texture = new_texture

func add_score() -> void:
	_create_card_stack()
	_configure_label()

func _configure_label() -> void:
	_label.set_new_score(_current_card_count)
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(_label, "offset_left", _current_spawn_position_x + max_size / 2, animation_time)

func _create_card_stack() -> void:
	_current_card_count += 1
	if _current_card_count >= max_visualized_cards:
		return
	print("spawn card")
	var cards: Array[TextureRect] = [
		_create_new_card(),
		_create_new_card()
	]
	var  index: int = 0
	for card: TextureRect in cards:
		_card_templates.append(card)
		add_child(card)
		card.offset_top = -150
		var tween: Tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)

		var time: float = animation_time
		if index > 0:
			time += animation_time_difference
		tween.tween_property(card, "offset_top", 0, time)
		tween.finished.connect(func() -> void: _card_animation_done.emit())
		index += 1
		
	

	_current_spawn_position_x += randf_range(min_separation, max_separation)
	pass

func _create_new_card() -> TextureRect:
	var card_template: TextureRect = TextureRect.new()
	card_template.custom_maximum_size = Vector2(max_size, max_size)
	card_template.offset_transform_enabled = true
	card_template.texture = _get_texture()
	card_template.offset_transform_rotation = deg_to_rad(randf_range(-rotation_limit_degree, rotation_limit_degree))
	card_template.offset_left = _current_spawn_position_x
	var target_modulate: Color = Color.WHITE
	if not _is_active:
		target_modulate.a = inactive_visibility
	return card_template
