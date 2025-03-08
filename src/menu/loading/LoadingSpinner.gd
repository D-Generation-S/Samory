class_name LoadingSpinner extends TextureRect


@export var animation: SpinnerAnimation = null

var current_time = 0
var index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if animation == null:
		printerr("No animation set for spinner")
		queue_free()
		return
	select_next_texture()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_time > animation.change_in_milliseconds / 1000:
		current_time = (animation.change_in_milliseconds / 1000) - current_time
		index = index + 1
		if index >= animation.images.size():
			index = 0
		select_next_texture()
	current_time = current_time + delta

func select_next_texture():
	texture = animation.images[index]

