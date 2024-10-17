extends Resource

class_name  DisolveEffectResource

## If the number is higher the effect is more common
@export_range(1, 20) var rarity: int = 1;

@export var effect_material: Material;

@export var remove_sound: AudioStream;

@export_range(0.01, 30) var effect_speed_multiplier: float = 1