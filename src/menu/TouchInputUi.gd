extends Button

enum {
	Web = 1,
	Desktop = 2,
	MobileWeb = 4
}

@export var input_action: String = ""
@export_flags("Web:1", "Desktop:2", "MobileWeb:4") var allowed_systems: int = 0;

@export_range(0, 1000, 10) var milliseconds_to_press: float = 100


var active: bool = false
var active_counter = 0;


func _ready():
	if !check_if_active():
		print_debug("Delete button because this is not a valid device!")
		queue_free()
	if input_action == "":
		printerr("Deleting touch button, cause no action was set")
		queue_free()

func check_if_active() -> bool:
	var result: bool = false
	if allowed_systems >= Web:
		result = OS.has_feature("web")
		allowed_systems = allowed_systems - Web
		if result:
			return result
	if allowed_systems >= Desktop:
		result = OS.has_feature("windows") or OS.has_feature("linux") or OS.has_feature("macos")
		allowed_systems = allowed_systems - Desktop
		if result:
			return result

	if allowed_systems >= MobileWeb:		
		result = OS.has_feature("web_android") or OS.has_feature("web_ios") or OS.has_feature("mobile")
		allowed_systems = allowed_systems - MobileWeb
		if result:
			return result

	return result

func _pressed():
	if active:
		return
	Input.action_press(input_action)
	active = true
	active_counter = 0

func _process(delta):
	if !active:
		return

	active_counter = active_counter + delta
	if active_counter > milliseconds_to_press / 1000:
		Input.action_release(input_action)
		active = false


func toggle_state(on: bool):
	visible = on



