shader_type canvas_item;

uniform float edge_fade_width : hint_range(0.0, 0.5) = 0.05;

void fragment() {
	float dist_left = UV.x;
	float dist_right = 1.0 - UV.x;
	float dist_bottom = UV.y;
	float dist_top = 1.0 - UV.y;
		
	float min_dist = min(min(dist_left, dist_right), min(dist_bottom, dist_top));
	float edge_fade = smoothstep(0.0, edge_fade_width, min_dist);
		
	COLOR.a = edge_fade;
}

