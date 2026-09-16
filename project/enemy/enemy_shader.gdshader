shader_type canvas_item;

uniform sampler2D atlas: filter_nearest;
uniform float hitflash: hint_range(0.0, 1.0) = 0.0;

global uniform float HITFLASH_STRENGTH;
global uniform float HITFLASH_SPEED;

void fragment()
{
	vec4 tex1 = texture(atlas, vec2(UV.x * 0.5, UV.y));
	vec4 tex2 = texture(atlas, vec2(0.5 + UV.x * 0.5, UV.y));

	float blink = 0.5 + sin(TIME * HITFLASH_SPEED) * 0.5;
	COLOR = mix(tex1, tex2, blink * hitflash * HITFLASH_STRENGTH);
}
