extends ClickableButton

signal player_added(new_player: PlayerResource)
signal adding_ai_player()
signal dialog_closed()

@export var ai_selecion_dialog: PackedScene

var currently_shown = false

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	if ai_selecion_dialog == null:
		printerr("Ai Selection is missing packed scene")
		visible = false

func _pressed():
	if ai_selecion_dialog == null or currently_shown:
		return
	super()
	currently_shown = true
	adding_ai_player.emit()
	var scene = ai_selecion_dialog.instantiate() as SelectAiPlayer
	scene.dialog_closed.connect(dialog_closing)
	scene.ai_added.connect(add_new_ai_player)
	add_child(scene)

func dialog_closing():
	currently_shown = false
	dialog_closed.emit()

func add_new_ai_player(ai: AiDifficultyResource):
	var player = PlayerResource.new()
	player.name = tr(ai.name)
	player.age = randi_range(200, 700)
	player.ai_difficulty = ai

	player_added.emit(player)
