extends Button

class_name ClickableButton

signal play_sound_effect(stream: AudioStream)

@export var click_sound: AudioStream
@export var hover_sound: AudioStream

func _pressed():
    if click_sound == null:
        return
    play_sound_effect.emit(click_sound)

func _hover():
    if hover_sound == null:
        return
    play_sound_effect.emit(hover_sound)

