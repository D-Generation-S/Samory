extends Node

signal game_menu_requested()
signal end_current_round()
signal confirm_current_card()
signal card_movement(information: Vector2)

@export var frames_to_skip_after_pause: int = 2

var current_ai_player: bool = false
var can_end_round: bool = false

var resumed_from_pause = false
var skipped_frames = 0

func _process(_delta):
	if resumed_from_pause:
		if skipped_frames > frames_to_skip_after_pause:
			resumed_from_pause = false
			skipped_frames = 0
		skipped_frames += 1
		return
	
	_handle_player_input_actions()
	_handle_special_player_actions()

func game_state_changed(game_state: int):
	match game_state:
		GameState.PREPARE_ROUND_END:
			can_end_round = true
		GameState.ROUND_START:
			can_end_round = false

func player_changed(current_player:PlayerResource):
	current_ai_player = current_player.is_ai()

func game_paused(is_paused: bool):
	resumed_from_pause = !is_paused

func _handle_special_player_actions():
	if Input.is_action_just_pressed("back"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		game_menu_requested.emit()
	if Input.is_action_just_pressed("next_round") and can_end_round:
		can_end_round = false
		end_current_round.emit()

func _handle_player_input_actions():
	if current_ai_player:
		return
	var movement = Vector2.ZERO
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