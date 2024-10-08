extends PanelContainer

class_name PlayerCard

signal getting_deleted()

@export var player_card: PlayerResource

@export var player_name_field: Label
@export var player_age_field: Label

var delete_queued: bool = false

func _ready():
	player_name_field.text = player_card.name
	player_age_field.text = str(player_card.age)

func delete_card():
	delete_queued = true
	getting_deleted.emit()
	queue_free()

func is_getting_deleted() -> bool:
	return delete_queued
