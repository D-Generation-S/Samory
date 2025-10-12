class_name LootTable extends Node

var loot_table: Array[Variant] = []

func add_to_table(object: Variant, amount: int) -> void:
    for i: int in amount:
        loot_table.append(object)

func clear_table() -> void:
    loot_table = []

func get_loot() -> Variant:
    if loot_table.size() == 0:
        return null
    loot_table.shuffle()
    return loot_table.pick_random()