extends CenterContainer

signal showing_container()
signal hiding_container()

@export var align_source: Control

var _is_active: bool = false

func _ready():
	if align_source == null:
		printerr("Align Source required")
		return
	await RenderingServer.frame_post_draw
	var global_rect = Rect2(align_source.global_position, align_source.size)
	global_position = global_rect.end
	global_position.y = global_position.y - global_rect.size.y / 2 - size.y / 2
	scale = Vector2.ZERO
	pivot_offset.y = size.y / 2

func toggle_menu():
	if _is_active:
		_hide_menu()
		return
	_show_menu()

func _show_menu():
	showing_container.emit()
	_is_active = true
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)

func _hide_menu():
	hiding_container.emit()
	_is_active = false
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)



