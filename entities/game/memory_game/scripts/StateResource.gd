class_name StateResource extends Resource

@export var source_state: GameEnum.State = GameEnum.State.GAME_INIT
@export var possible_states: Array[GameEnum.State] = []

func state_switch_allowed(new_state: GameEnum.State) -> bool:
	print(new_state)
	print(possible_states)
	for state: GameEnum.State in possible_states:
		if new_state == state:
			return true
	return false