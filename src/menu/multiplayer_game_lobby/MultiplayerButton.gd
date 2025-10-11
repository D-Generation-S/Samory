class_name MultiplayerButton extends ClickableButton

@export var is_server_only: bool = false

func _ready() -> void:
	super()
	if !is_server_only:
		return
	await get_tree().physics_frame
	if !multiplayer.is_server():
		queue_free()
		return