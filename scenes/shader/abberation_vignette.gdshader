shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest_mipmap, repeat_enable;

uniform float alpha : hint_range(0.0, 1.0);
uniform float scale : hint_range(1.0, 2.0);
uniform float border_mask: hint_range(0.0, 5.0) = 2.0;
uniform float strength : hint_range(0, 25);

void fragment() {
	float scale_reverse = 2.0 - scale;
	vec2 uvs = SCREEN_UV * scale_reverse + vec2(1.0 - scale_reverse)/2.;
	
	vec2 mask = pow(2.0 * abs(UV - 0.5), vec2(border_mask));
	
	float r = texture(screen_texture, (uvs + vec2(SCREEN_PIXEL_SIZE * strength) * mask), 0.0).r;
	float g = texture(screen_texture, (uvs + vec2(SCREEN_PIXEL_SIZE) * mask), 0.0).g;
	float b = texture(screen_texture, (uvs + vec2(SCREEN_PIXEL_SIZE * strength) *mask), 0.0).b;
	
	COLOR = vec4(r, g, b, alpha);
}