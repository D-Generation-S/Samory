@tool
class_name MemoryCardResource extends Resource

@export var name: String:
    set(value):
        name = value
        if Engine.is_editor_hint():
            description = value + "_DESCRIPTION"
            
@export var description: String = ""
@export var texture: Texture2D

var id: int = -1

func set_id(new_id: int):
    if id != -1:
        return
    id = new_id

func get_id():
    return id