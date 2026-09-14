shader_type canvas_item;

uniform sampler2D bar_texture: filter_nearest;
uniform sampler2D damage_texture: filter_nearest, repeat_enable;
uniform sampler2D overlay_texture: filter_nearest;

const float LEFT_MARGIN = 4.0;
const float RIGHT_MARGIN = 4.0;
const vec2 TEX_SIZE = vec2(10.0, 10.0);

const float OVERLAY_LEFT_MARGIN = 4.0;
const float OVERLAY_RIGHT_MARGIN = 4.0;
const vec2 OVERLAY_TEX_SIZE = vec2(10.0, 10.0);

uniform vec2 node_size = vec2(200.0, 32.0);

uniform float progress : hint_range(0.0, 1.0) = 1.0;
uniform float damage_progress : hint_range(0.0, 1.0) = 1.0;

uniform vec2 damage_scroll_speed = vec2(0.25, 0.1);

uniform vec2 damage_tile_size = vec2(10.0, 10.0);

vec2 slice_uv_generic(float px, float left_margin, float right_margin, float tex_w)
{
    float new_x;

    if (px < left_margin)
    {
        new_x = px;
    }
    else if (px > node_size.x - right_margin)
    {
        float dist_from_right = node_size.x - px;
        new_x = tex_w - dist_from_right;
    }
    else
    {
        float t = (px - left_margin) / max(node_size.x - left_margin - right_margin, 0.0001);
        new_x = left_margin + t * (tex_w - left_margin - right_margin);
    }

    return vec2(new_x / tex_w, 0.0);
}

vec2 slice_uv(float px)
{
    return slice_uv_generic(px, LEFT_MARGIN, RIGHT_MARGIN, TEX_SIZE.x);
}

vec2 overlay_slice_uv(float px)
{
    return slice_uv_generic(px, OVERLAY_LEFT_MARGIN, OVERLAY_RIGHT_MARGIN, OVERLAY_TEX_SIZE.x);
}

void fragment()
{
	float trailing = max(damage_progress, progress);

    float px = UV.x * node_size.x;
    vec2 new_uv = slice_uv(px);
    new_uv.y = UV.y;

    if (UV.x <= progress)
    {
        COLOR = texture(bar_texture, new_uv) * COLOR;
    }
    else if (UV.x <= trailing)
    {
        vec2 tile_uv = vec2(px, UV.y * node_size.y) / damage_tile_size;
        tile_uv += TIME * damage_scroll_speed;
        vec4 damage_color = texture(damage_texture, tile_uv);

        float shape_mask = texture(bar_texture, new_uv).a;

        COLOR = vec4(damage_color.rgb, damage_color.a * shape_mask) * COLOR;
    }
    else
    {
        COLOR = vec4(0.0);
    }

    vec2 overlay_uv = overlay_slice_uv(px);
    overlay_uv.y = UV.y;
    vec4 overlay_color = texture(overlay_texture, overlay_uv);

    vec3 out_rgb = overlay_color.rgb * overlay_color.a + COLOR.rgb * (1.0 - overlay_color.a);
    float out_a = overlay_color.a + COLOR.a * (1.0 - overlay_color.a);
    COLOR = vec4(out_rgb, out_a);
}