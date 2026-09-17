shader_type canvas_item;

uniform sampler2D gradient_ramp : source_color;
uniform bool use_rec709 = false;

void fragment()
{
    vec4 tex_color = texture(TEXTURE, UV);

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
}