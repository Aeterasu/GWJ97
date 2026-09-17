shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, repeat_disable, filter_nearest;

float overlay_channel(float base, float blend)
{
    return base < 0.5
        ? 2.0 * base * blend
        : 1.0 - 2.0 * (1.0 - base) * (1.0 - blend);
}

void fragment()
{
    vec3 base = texture(screen_tex, SCREEN_UV).rgb;
    vec3 blend = COLOR.rgb;

    vec3 result = vec3(
        overlay_channel(base.r, blend.r),
        overlay_channel(base.g, blend.g),
        overlay_channel(base.b, blend.b)
    );

    COLOR.rgb = mix(base, result, COLOR.a); // respect alpha
    COLOR.a = 1.0;
}