shader_type canvas_item;

uniform sampler2D sun_texture: filter_nearest;

void fragment()
{
	vec4 texture_1 = texture(sun_texture, vec2(UV.x * 0.5, UV.y));
	vec4 texture_2 = texture(sun_texture, vec2(0.5 + UV.x * 0.5, UV.y));
	
	float a = 0.5 + (sin(TIME * 15.0) * 0.5);
	
	COLOR = mix(texture_1, texture_2, a);
}