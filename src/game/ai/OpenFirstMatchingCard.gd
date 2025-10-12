class_name OpenFirstMatchingCard extends AiBehaviorNode

func can_execute(blackboard: Blackboard, grid: GameCardGrid) -> bool:
    return grid.get_all_cards_currently_turned().size() == 0 and _blackboard_contains_identical_cards(blackboard)

func _get_blackboard_identical_cards(blackboard: Blackboard) -> Array[CardInformationResource]:
    var known_cards: Array[CardInformationResource] = blackboard.get_all_saved_cards()
    var pairs: Array[CardInformationResource] = []
    for card: CardInformationResource in known_cards:
        for other_card: CardInformationResource in known_cards:
            if other_card.card.id == card.card.id and !other_card.position.is_identical(card.position):
                pairs.append(card)
                pairs.append(other_card)
    return pairs

func _blackboard_contains_identical_cards(blackboard: Blackboard) -> bool:
    return _get_blackboard_identical_cards(blackboard).size() > 0

func execute_action(blackboard: Blackboard, grid: GameCardGrid) -> void:
    print_debug("OpenFirstMatchingCard")
    var cards: Array[CardInformationResource] = _get_blackboard_identical_cards(blackboard)
    var index: int = randi_range(0, cards.size() - 1)
    _trigger_card(cards[index].position, blackboard, grid)
