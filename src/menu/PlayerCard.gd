extends PanelContainer

class_name PlayerCard

signal getting_deleted()
signal move_up_request(current_id: int)
signal move_down_request(current_id: int)
signal regain_focus_request()

@export var player_card: PlayerResource
@export var human_player_icon: Texture
@export var ai_player_icon: Texture
@export var icon_target: TextureRect

@export var player_name_field: Label

var delete_queued: bool = false

func _ready():
	var name_suffix = ""
	if  player_card.is_ai():
		name_suffix = " [AI]"
	player_name_field.text = player_card.name + name_suffix
	var icon = human_player_icon
	if player_card.is_ai():
		icon = ai_player_icon
	icon_target.texture = icon

func delete_card():
	delete_queued = true
	getting_deleted.emit()
	queue_free()

func is_getting_deleted() -> bool:
	return delete_queued

func move_up():
	move_up_request.emit(player_card.order_number)

func move_down():
	move_down_request.emit(player_card.order_number)

func regain_focus():
	regain_focus_request.emit()