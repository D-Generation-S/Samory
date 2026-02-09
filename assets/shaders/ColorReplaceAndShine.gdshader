shader_type canvas_item;

uniform bool always_replace = false;
uniform vec4 base_color: source_color = vec4(0, 0, 0, 0);
uniform vec4 target_color: source_color = vec4(0, 0, 0, 0);
uniform float tolerance: hint_range(0., 1.) = 0.1;

uniform bool should_shine = false;
uniform vec4 shine_color: source_color = vec4(1.0, 1.0, 1.0, 0.25);

uniform float line_width: hint_range(0.0, 2.0, 0.001) = 0.1;
uniform float angle: hint_range(0.0, 6.28318530718, 0.1308996939) = 0.785398163397;

uniform float speed: hint_range(0.0, 10.0, 0.1) = 1.0;
uniform float wait_cycles: hint_range(0.0, 10.0, 0.1) = 1.0;

// Shine based on https://godotshaders.com/shader/shine/
vec2 rotate_precalculated(vec2 _pos, float _sine, float _cosine)
{
	return vec2(_pos.x * _cosine + _pos.y * -_sine, _pos.x * _sine + _pos.y * _cosine);
}

vec4 apply_shine(vec4 color_data, vec2 uv_data)
{
	if (!should_shine)
	{
		return color_data;
	}
	float sine = sin(angle);
	float cosine = cos(angle);
	float len = 1.5 - max(abs(sine), abs(cosine)) + line_width;
	float line = smoothstep(-line_width,
							line_width, 
							rotate_precalculated((uv_data - vec2(0.5)), sine, cosine).y - mod(TIME * speed, (len * 2.0) * wait_cycles) + len
							);
	color_data.rgb += shine_color.rgb * shine_color.a * vec3(line * (1.0 - line) * 4.0);
	return color_data;
}

void fragment()
{
	vec4 pixel = texture(TEXTURE, UV);
	float dist = length(pixel.rgb - base_color.rgb);
	
	float should_replace = always_replace ? 0. : step(tolerance, dist);
	
	vec4 result = mix(target_color, pixel, should_replace);
	
	result.a = pixel.a;
	
	result = apply_shine(result, UV);
	COLOR = result;
}
