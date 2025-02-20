class_name OpenFirstMatchingCard extends AiBehaviorNode

func can_execute(blackboard: Blackboard, grid: GameCardGrid) -> bool:
    return grid.get_all_cards_currently_turned().size() == 0 and blackboard_contains_identical_cards(blackboard)

func get_blackboard_intentical_cards(blackboard: Blackboard) -> Array[CardInformationResource]:
    var known_cards = blackboard.get_all_saved_cards()
    var pairs: Array[CardInformationResource] = []
    for card in known_cards:
        for other_card in known_cards:
            if other_card.card.id == card.card.id and !other_card.position.is_identical(card.position):
                pairs.append(card)
                pairs.append(other_card)
    return pairs

func blackboard_contains_identical_cards(blackboard: Blackboard) -> bool:
    return get_blackboard_intentical_cards(blackboard).size() > 0

func execute_action(blackboard: Blackboard, grid: GameCardGrid):
    print("OpenFirstMatchingCard")
    var cards = get_blackboard_intentical_cards(blackboard)
    var index = randi_range(0, cards.size() - 1)
    trigger_card(cards[index].position, blackboard, grid)
