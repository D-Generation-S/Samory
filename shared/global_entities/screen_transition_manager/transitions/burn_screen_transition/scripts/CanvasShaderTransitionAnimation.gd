extends TextureRect

@export var shader_progress_control_name: String = "progress"
@export var target_shader_value: float = 1.0
@export var reverted_shader: bool = false
@export var click_position_control_name: String = "position"


func set_click_position(global_screen_position: Vector2) -> void:
	var local_shader_position: Vector2 = global_screen_position / texture.get_size()
	material.set_shader_parameter(click_position_control_name, local_shader_position)

func transition_step(step_number: float) -> void:
	var real_value: float = step_number * target_shader_value
	if (reverted_shader):
		real_value = target_shader_value - real_value
	material.set_shader_parameter(shader_progress_control_name, real_value)
