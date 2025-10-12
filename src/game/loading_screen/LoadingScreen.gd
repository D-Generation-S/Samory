extends Node2D

class_name LoadingScreen

signal loading_done()
signal loaded_scene(new_node: Node)

@export var screen_message: Label
@export var static_label: Label
@export var sound_effect: AudioStream
@export var play_effects: bool = true

var loading_target_node: Node = null

var elapsed_time: float = 0
var effect_length: float = 1000000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	effect_length = sound_effect.get_length()
	elapsed_time = effect_length
	screen_message.text = ""

func _process(delta: float) -> void:
	if elapsed_time > effect_length and play_effects:
		GlobalSoundManager.play_sound_effect(sound_effect)
		elapsed_time = elapsed_time - effect_length
	elapsed_time = elapsed_time + delta

func set_screen_message(new_text: String, remove_default_label: bool = false) -> void:
	screen_message.text = new_text
	if remove_default_label:
		static_label.visible = false

func set_follow_up_node(target_node: Node) -> void:
	if target_node == null:
		printerr("No node was provided!")
		return
	loading_target_node = target_node

func set_follow_up_screen(scene: PackedScene) -> void:
	if scene == null:
		printerr("No scene was provided!")
		return
	set_follow_up_node(scene.instantiate())

func destroy() -> void:
	GlobalSoundManager.stop_all_sounds()
	process_mode = Node.PROCESS_MODE_DISABLED
	loading_done.emit()
	if loading_target_node == null:
		return
	var transition: AnimationScene = await ScreenTransitionManager.transit_screen_by_node_with_position(loading_target_node, DisplayServer.window_get_size() / 2, false)
	transition.animation_done.connect(func(_scene: Node) -> void:
		queue_free()
		if not loading_target_node.is_in_group("active_scene"):
			loading_target_node.add_to_group("active_scene")
		)

	for child: Node in get_children():
		if child is Node2D:
			child.visible = false
		if child is Control or child is CanvasLayer:
			child.hide()
	loaded_scene.emit(loading_target_node)
