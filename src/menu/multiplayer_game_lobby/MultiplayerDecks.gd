extends PanelContainer

func _ready() -> void:
	await get_tree().physics_frame
	if !multiplayer.is_server():
		queue_free()