shader_type canvas_item;

uniform sampler2D noiseTexture;
uniform vec3 burnColor: source_color = vec3(0,0,0); 
uniform float threshold: hint_range(0.0, 1.0) = 0;
uniform float edgeWidth : hint_range(0.0, 0.2) = 0.1;


void fragment() {
	float noiseValue = texture(noiseTexture, UV).r;
	float alpha = COLOR.a;
	float edge = 0.0;
	if (threshold > 0.0)
	{
		edge = 1.0 - smoothstep(threshold, threshold + edgeWidth, noiseValue);
		 alpha = step(threshold, noiseValue);
	}
	vec3 finalColor = mix(COLOR.rgb, burnColor, edge);
	
	COLOR.rgb = finalColor.rgb;
	COLOR.a = alpha;
}
