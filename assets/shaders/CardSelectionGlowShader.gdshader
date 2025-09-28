shader_type canvas_item;

uniform float border_percentage:hint_range(0, 25) = 2;
uniform vec4 effect_color: source_color = vec4(0., 0., 0., 1.);
uniform float frequenzy: hint_range(0.1, 5) = 1;
uniform float border_shift: hint_range(0.5, 0.9) = 0.5;
uniform bool pulse_active = true;

float get_border_mix(float uv_coord, float border, float alpha)
{
	float distance_to_edge = min(uv_coord, 1.0 - uv_coord);
	float percentage = 1. - distance_to_edge / border;
	
	return clamp(percentage, 0., 1.) * alpha;
}

void fragment() {
	vec4 pixel_color = texture(TEXTURE, UV);
	float pulse = pulse_active
					? clamp((1. - border_shift) * sin(TIME / frequenzy) + border_shift, 0., 1.)
					: 1.;

	float border = border_percentage / 100.;
	float effect_alpha = effect_color.a * pulse;
	
	float min_x = get_border_mix(UV.x, border, effect_alpha);
	float min_y = get_border_mix(UV.y, border, effect_alpha);
	float mix_factor = max(min_x, min_y);

	COLOR = mix(pixel_color, effect_color, mix_factor);
}

