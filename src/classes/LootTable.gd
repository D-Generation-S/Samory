extends  Node

class_name LootTable

var loot_table: Array = []

func add_to_table(object, amount: int):
    for i in range(amount):
        loot_table.append(object)

func clear_table():
    loot_table = []

func get_loot():
    if loot_table.size() == 0:
        return null
    loot_table.shuffle()
    var index = randi_range(0, loot_table.size() - 1)
    return loot_table[index]