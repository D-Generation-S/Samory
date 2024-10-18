shader_type canvas_item;


//Based on: https://www.youtube.com/watch?v=AIGLcHSKgv8
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

uniform sampler2D noise_texture;
uniform sampler2D gradient_texture;

uniform float progress: hint_range(0.0, 1.0) = 0;
uniform float burn_size: hint_range(0.0, 153) = 1.3;


float inverse_lerp(float a, float b, float y) {
	return (y - a) / (b - a);
}

void fragment()
{
	float integrity = 1. - progress;
	
	float noise = texture(noise_texture, UV).r * (UV.y);
	
	vec4 base_color = texture(SCREEN_TEXTURE, SCREEN_UV) * step(noise, integrity);
	vec2 burn_uv = vec2(inverse_lerp(integrity, integrity * burn_size, noise), 0.0);
	
	vec4 burn_color = texture(gradient_texture, burn_uv) * step(noise, integrity * burn_size);
	COLOR = mix(burn_color, base_color, base_color.a);
	
}

