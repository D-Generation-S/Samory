class_name GetMatchingCard extends AiBehaviorNode

func can_execute(blackboard: Blackboard, grid: GameCardGrid) -> bool:
    var unvealed_card = get_current_unvealed_card(grid)
    if unvealed_card == null:
        return false;

    var loaded_card = grid.get_card_on_position(unvealed_card)    
    if loaded_card == null:
        return false;
    var stored_cards = blackboard.get_all_cards_with_id(loaded_card.id)
    for stored_card in stored_cards:
        if !stored_card.position.is_identical(unvealed_card):
            return true
    return false

func get_current_unvealed_card(grid: GameCardGrid) -> Point:
    var all_cards = grid.get_all_card_positions(true)
    var unknown_cards = grid.get_all_card_positions(false)
    var left_over_cards: Array[Point] = []
    for card in all_cards:
        var add_card = true
        for unknown_card in unknown_cards:
            if card.is_identical(unknown_card):
                add_card = false
        if add_card:
            left_over_cards.append(card)

    var current_card = null
    if left_over_cards.size() > 0:
        current_card = left_over_cards[0]
    return current_card

func execute_action(blackboard: Blackboard, grid: GameCardGrid):
    print("GetMatchingCard")
    var unvealed_card = get_current_unvealed_card(grid)
    var loaded_card = grid.get_card_on_position(unvealed_card)
    var card_to_reveal: CardInformationResource = null
    var stored_cards = blackboard.get_all_cards_with_id(loaded_card.id)

    for stored_card in stored_cards:
        if !stored_card.position.is_identical(unvealed_card):
            card_to_reveal = stored_card
    trigger_card(card_to_reveal.position, blackboard, grid)
