shader_type canvas_item;

uniform sampler2D atlas: filter_nearest;
uniform bool is_invul = false;
uniform float is_focused : hint_range(0.0, 1.0) = 0.0;

void fragment()
{
	vec2 uv1 = vec2(UV.x / 3.0 + 0.0 / 3.0, UV.y);
	vec2 uv2 = vec2(UV.x / 3.0 + 1.0 / 3.0, UV.y);
	vec2 uv3 = vec2(UV.x / 3.0 + 2.0 / 3.0, UV.y);

	vec4 tex1 = texture(atlas, uv1);
	vec4 tex2 = texture(atlas, uv2);
	vec4 tex3 = texture(atlas, uv3);

	float blink = 0.5 - sin(TIME * 35.0) * 0.5;
	float factor = blink * float(is_invul);;

	COLOR = mix(mix(tex1, tex2, is_focused), tex3, factor);
}