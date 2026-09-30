class_name GameLanguage extends Resource

@export var order_id: int = 0
@export var display_name: TextTranslation
@export var iso_code: String
@export var icon: Texture2D

func is_valid() -> bool:
	return display_name != null and not iso_code.is_empty()