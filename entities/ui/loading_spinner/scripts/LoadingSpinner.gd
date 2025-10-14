class_name LoadingSpinner extends TextureRect


@export var animation: SpinnerAnimation = null

var _index: int = 0
var _timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if animation == null:
		printerr("No animation set for spinner")
		queue_free()
		return
	select_next_texture()
	_timer = Timer.new()
	_timer.wait_time = animation.change_in_milliseconds / 1000
	_timer.autostart = true
	_timer.one_shot = false
	_timer.timeout.connect(_timeout)

	add_child(_timer)

func _timeout() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "texture", animation.images[_index], animation.change_in_milliseconds / 1000)
	_increase_index()

func _increase_index() -> void:
	_index = _index + 1
	if _index >= animation.images.size():
		_index = 0

func select_next_texture() -> void:
	texture = animation.images[_index]

