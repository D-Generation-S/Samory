class_name GetMatchingCard extends AiBehaviorNode

func can_execute(blackboard: Blackboard, grid: GameCardGrid) -> bool:
    var unvealed_cards = grid.get_all_cards_currently_turned()
    if unvealed_cards.size() != 1:
        return false;

    var card_of_focus = unvealed_cards[0]
    var loaded_card = grid.get_card_on_position(card_of_focus)    
    if loaded_card == null:
        return false;
    var stored_cards = blackboard.get_all_cards_with_id(loaded_card.id)
    for stored_card in stored_cards:
        if !stored_card.position.is_identical(card_of_focus):
            return true
    return false

func execute_action(blackboard: Blackboard, grid: GameCardGrid):
    print("GetMatchingCard")
    var unvealed_cards = grid.get_all_cards_currently_turned()
    var card_of_focus = unvealed_cards[0]
    var loaded_card = grid.get_card_on_position(card_of_focus)
    var card_to_reveal: CardInformationResource = null
    var stored_cards = blackboard.get_all_cards_with_id(loaded_card.id)

    for stored_card in stored_cards:
        if !stored_card.position.is_identical(card_of_focus):
            card_to_reveal = stored_card
    trigger_card(card_to_reveal.position, blackboard, grid)
