shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

uniform vec2 fragment_number = vec2(20, 20);
uniform float progress: hint_range(0.0, 1.0) = 0;


void fragment() {
	float real_progress = 1. - progress;
	vec2 pixel_fract = fract(UV * fragment_number);
	float pixel_dist = distance(pixel_fract, vec2(0.5, 0.5));
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	COLOR.a *= step(pixel_dist, real_progress); // texture(SCREEN_TEXTURE, SCREEN_UV);
}
