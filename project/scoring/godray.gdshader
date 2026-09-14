shader_type canvas_item;
render_mode unshaded, blend_add;

uniform sampler2D gradient: filter_nearest;
uniform float base_alpha = 0.5;
uniform float alpha_speed = 2.0;

void fragment()
{
	COLOR *= texture(gradient, UV);
	
	float a = 0.5 + sin(TIME * alpha_speed) * 0.5;
	COLOR.a *= base_alpha;
	COLOR.a *= a;
}