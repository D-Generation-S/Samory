shader_type canvas_item;

uniform bool always_replace = false;
uniform vec4 base_color: source_color = vec4(0, 0, 0, 0);
uniform vec4 target_color: source_color = vec4(0, 0, 0, 0);
uniform float tolerance: hint_range(0., 1.) = 0.1;

void fragment()
{
	vec4 pixel = texture(TEXTURE, UV);
	float dist = length(pixel.rgb - base_color.rgb);
	
	float should_replace = always_replace ? 0. : step(tolerance, dist);
	
	vec4 result = mix(target_color, pixel, should_replace);
	
	result.a = pixel.a;
	
	COLOR = result;	
}
