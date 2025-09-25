class_name ClickableFoldable extends FoldableContainer

@export_group("Fold behavior")
@export var folded_neighbor: NodePath
@export var unfolded_neighbor: NodePath

@export_group("Effects")
@export var hover_sound: AudioStream
@export var click_sound: AudioStream

func _ready():
	_setup_sounds()
	_update_bottom_neighbor()
		
func _update_bottom_neighbor():
	focus_neighbor_bottom = unfolded_neighbor
	if folded:
		focus_neighbor_bottom = folded_neighbor

func _setup_sounds():
	if hover_sound != null:
		mouse_entered.connect(_on_focus_entered)
		focus_entered.connect(_on_focus_entered)
	if click_sound != null:
		folding_changed.connect(_on_clicked)

func _on_focus_entered():
	GlobalSoundManager.play_sound_effect(hover_sound)

func _on_clicked(_folding_state: bool):
	GlobalSoundManager.play_sound_effect(click_sound)
	_update_bottom_neighbor()