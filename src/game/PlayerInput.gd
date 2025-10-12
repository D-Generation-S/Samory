extends Node

signal game_menu_requested()
signal end_current_round()
signal confirm_current_card()
signal card_movement(information: Vector2)
signal disable_input()

@export var frames_to_skip_after_pause: int = 2

var current_ai_player: bool = false
var can_end_round: bool = false

var resumed_from_pause: bool = false
var skipped_frames: int = 0

func _process(_delta: float) -> void:
	if resumed_from_pause:
		if skipped_frames > frames_to_skip_after_pause:
			resumed_from_pause = false
			skipped_frames = 0
		skipped_frames += 1
		return
	
	_handle_player_input_actions()
	_handle_special_player_actions()

func game_state_changed(game_state: int) -> void:
	match game_state:
		GameState.PREPARE_ROUND_END:
			can_end_round = true
		GameState.ROUND_START:
			can_end_round = false

func player_changed(current_player:PlayerResource) -> void:
	current_ai_player = current_player.is_ai()
	if multiplayer.get_peers().size() > 0 and current_player.id != multiplayer.get_unique_id():
		current_ai_player = true
	if current_ai_player:
		disable_input.emit()

func game_paused(is_paused: bool) -> void:
	resumed_from_pause = !is_paused

func _handle_special_player_actions() -> void:
	if Input.is_action_just_pressed("back"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		game_menu_requested.emit()
	if Input.is_action_just_pressed("next_round") and can_end_round:
		can_end_round = false
		end_current_round.emit()

func _handle_player_input_actions() -> void:
	if current_ai_player or can_end_round:
		return
	var movement: Vector2 = Vector2.ZERO
	if Input.is_action_just_pressed("move_left"):
		movement.x = -1
	if Input.is_action_just_pressed("move_right"):
		movement.x = 1

	if Input.is_action_just_pressed("move_up"):
		movement.y = -1
	if Input.is_action_just_pressed("move_down"):
		movement.y = 1

	if Input.is_action_just_pressed("confirm") and !current_ai_player:
		confirm_current_card.emit()

	if !is_zero_approx(movement.x) || !is_zero_approx(movement.y):
		card_movement.emit(movement)
