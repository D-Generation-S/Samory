extends VBoxContainer

signal request_player_list()
signal player_kicked(id: int)

@export var player_template: PackedScene = null

func _ready():
	if player_template == null:
		printerr("Missing proper player template")
		queue_free()
	request_player_list.emit()

func player_added(new_name: String, id: int):
	var instance: PlayerCard = player_template.instantiate() as PlayerCard
	instance.getting_deleted.connect(player_card_delete)
	instance.can_delete = id != multiplayer.get_unique_id()
	if !multiplayer.is_server():
		instance.can_delete = false
	var player: PlayerResource = PlayerResource.new()
	player.name = new_name
	player.id = id
	player.order_number = 0
	player.ai_difficulty = null

	instance.player_card = player

	add_child(instance)

func player_card_delete():
	for child in get_children():
		if child is PlayerCard and child.delete_queued:
			var player: PlayerResource = child.player_card
			player_kicked.emit(player.id)
	pass

func player_disconnected(name: String, id: int):
	pass