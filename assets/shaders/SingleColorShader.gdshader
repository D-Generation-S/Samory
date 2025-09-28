shader_type canvas_item;

uniform float alpha_threshold: hint_range(0., 1.) = 0.58;
uniform vec4 replace_color: source_color = vec4(0,0,0,0);

void fragment() {
	float alpha = step(alpha_threshold, COLOR.a);
	COLOR.a = mix(COLOR.a, replace_color.a, alpha);
	COLOR.rbg = replace_color.rgb;
}
