shader_type canvas_item;

uniform float border_percentage:hint_range(0, 25) = 2;
uniform vec4 effect_color: source_color = vec4(0., 0., 0., 1.);
uniform float frequenzy: hint_range(0.1, 5) = 1;
uniform float border_shift: hint_range(0.5, 0.9) = 0.5;
uniform bool pulse_active = true;

void vertex() {
}

void fragment() {
	vec4 pixelColor = texture(TEXTURE, UV);
	float pulse = clamp((1. - border_shift) * sin(TIME / frequenzy) + border_shift, 0., 1.);
	if (!pulse_active)
	{
		pulse = 1.;
	}

	vec2 border = vec2(border_percentage / 100. , border_percentage / 100.);
	if (UV.x < border.x)
	{
		float percentage = 1.0 - UV.x / border.x;
		percentage *= effect_color.a;
		pixelColor.rgb = mix(pixelColor.rgb, effect_color.rgb, percentage * pulse);
	}
	if (UV.x > 1.0 - border.x)
	{
		float uv_base = 1. - UV.x;
		float percentage = 1.0 - uv_base / border.x;
		percentage *= effect_color.a;
		pixelColor.rgb = mix(pixelColor.rgb, effect_color.rgb, percentage * pulse);
	}
	if (UV.y < border.y)
	{
		float percentage = 1.0 - UV.y / border.y;
		percentage *= effect_color.a;
		pixelColor.rgb = mix(pixelColor.rgb, effect_color.rgb, percentage * pulse);
	}
	if (UV.y > 1.0 - border.y)
	{
		float uv_base = 1. - UV.y;
		float percentage = 1.0 - uv_base / border.y;
		percentage *= effect_color.a;
		pixelColor.rgb = mix(pixelColor.rgb, effect_color.rgb, percentage * pulse);
	}

	COLOR = pixelColor;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
