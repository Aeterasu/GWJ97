shader_type canvas_item;

uniform sampler2D invulnerable_sprite: filter_nearest;
uniform bool is_invul = false;

void fragment()
{
	vec4 tex = texture(TEXTURE, UV);
	vec4 invul_tex = texture(invulnerable_sprite, UV);
	
	float blink = 0.5 - sin(TIME * 75.0) * 0.5;
	float factor = blink * float(is_invul);
	
	COLOR = mix(tex, invul_tex, factor);
}