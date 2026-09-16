shader_type canvas_item;
render_mode unshaded;

uniform sampler2D stripe_texture : filter_nearest, repeat_enable;
uniform vec2 scroll_speed = vec2(1.0, 0.0);
uniform vec2 tiling = vec2(1.0, 4.0);
uniform float alpha : hint_range(0.0, 1.0) = 1.0;

void fragment()
{
	vec2 tiled_uv = UV * tiling;
	tiled_uv += TIME * scroll_speed;
	COLOR = texture(stripe_texture, tiled_uv);
	COLOR.a *= alpha;
}