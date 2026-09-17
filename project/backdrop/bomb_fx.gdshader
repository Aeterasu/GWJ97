shader_type canvas_item;
render_mode blend_add;

uniform vec2 scroll_speed = vec2(0.1, 0.0);

uniform float alpha: hint_range(0.0, 1.0) = 1.0;

uniform sampler2D gradient_ramp : source_color;
uniform bool use_rec709 = false;

void fragment()
{
	vec2 uv = UV + TIME * scroll_speed;
	
    vec4 tex_color = texture(TEXTURE, fract(uv));

    float luminosity;
    if (use_rec709)
	{
        luminosity = dot(tex_color.rgb, vec3(0.2126, 0.7152, 0.0722));
    }
	else
	{
        luminosity = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
    }

    vec4 mapped = texture(gradient_ramp, vec2(luminosity, 0.5));

    COLOR = vec4(mapped.rgb, mapped.a * tex_color.a);
	COLOR.a *= alpha;
}