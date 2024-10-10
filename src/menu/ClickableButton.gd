extends Button

class_name ClickableButton

var sound_bridge: SoundBridge = null

func _ready():
	load_sound_bridge()

func load_sound_bridge() -> bool:
	if sound_bridge != null:
		return true
	var game_manager = get_tree().root.get_child(0) as GameManager
	sound_bridge = game_manager.sound_bridge
	if sound_bridge == null:
		printerr("Sound bridge not found")
	return sound_bridge != null

func _pressed():
	if !load_sound_bridge():
		return
	sound_bridge.play_button_click()

func _hover():
	if !load_sound_bridge():
		return
	sound_bridge.play_button_hover()
