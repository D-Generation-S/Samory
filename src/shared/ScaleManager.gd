extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.has_feature("web_android") or OS.has_feature("web_ios"):
		get_window().content_scale_factor = 2.2

	queue_free()

