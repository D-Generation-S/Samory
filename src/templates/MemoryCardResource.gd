extends Resource

class_name MemoryCardResource

@export var name: String
@export var description: String
@export var texture: Texture2D

var id: int = -1

func set_id(new_id: int):
    if id != -1:
        return
    id = new_id

func get_id():
    return id