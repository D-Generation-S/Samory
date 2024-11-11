class_name OpenRandomCard extends AiBehaviorNode

func execute_action(blackboard: Blackboard):
    var cards = ai_node.get_all_card_positions()
    var index = randi() % cards.size()
    ai_node.trigger_card(cards[index])
