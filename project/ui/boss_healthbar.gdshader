shader_type canvas_item;

uniform sampler2D bar_texture: filter_nearest;
uniform sampler2D damage_texture: filter_nearest;

const float LEFT_MARGIN = 4.0;
const float RIGHT_MARGIN = 4.0;
const vec2 TEX_SIZE = vec2(10.0, 10.0);

uniform vec2 node_size = vec2(200.0, 32.0);

uniform float progress : hint_range(0.0, 1.0) = 1.0;
uniform float damage_progress : hint_range(0.0, 1.0) = 1.0;

vec2 slice_uv(float px)
{
    float tex_w = TEX_SIZE.x;
    float new_x;

    if (px < LEFT_MARGIN)
    {
        new_x = px;
    }
    else if (px > node_size.x - RIGHT_MARGIN)
    {
        float dist_from_right = node_size.x - px;
        new_x = tex_w - dist_from_right;
    }
    else
    {
        float t = (px - LEFT_MARGIN) / max(node_size.x - LEFT_MARGIN - RIGHT_MARGIN, 0.0001);
        new_x = LEFT_MARGIN + t * (tex_w - LEFT_MARGIN - RIGHT_MARGIN);
    }

    return vec2(new_x / tex_w, 0.0);
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
        COLOR = texture(damage_texture, new_uv) * COLOR;
    }
    else
    {
        COLOR = vec4(0.0);
    }
}