shader_type canvas_item;
render_mode unshaded;

uniform sampler2D stripe_texture : filter_nearest, repeat_enable;
uniform float scroll_speed = 1.0;
uniform vec2 tiling = vec2(1.0, 4.0); // x = horizontal repeats, y = vertical repeats

void fragment()
{
	vec2 tiled_uv = UV * tiling;
	tiled_uv.y += TIME * scroll_speed;
	COLOR = texture(stripe_texture, tiled_uv);
}