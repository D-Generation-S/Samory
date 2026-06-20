class_name GameEnum
# @TODO replace with global enum
enum State {
	GAME_INIT = 0, # Can only lead to "start"
    TURN_START = 10, # Can only go to turn completed
	TURN_COMPLETED = 20, # Can only go to freeze
    TURN_FREEZE = 30, # Can go to prepare turn end or turn start
    PREPARE_TURN_END = 40, # Can go to turn end or end game
    TURN_END = 50, # Can go to  turn start
	GAME_END = 1000
    }