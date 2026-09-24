shader_type canvas_item;

uniform sampler2D atlas: filter_nearest;
uniform bool is_invul = false;
uniform float is_focused : hint_range(0.0, 1.0) = 0.0;

uniform bool cull_backface = true;
uniform float fov : hint_range(1.0, 179.0) = 90.0;
uniform float rot_y_deg : hint_range(-360.0, 360.0) = 0.0;
uniform float rot_x_deg : hint_range(-360.0, 360.0) = 0.0;
uniform float inset : hint_range(0.0, 1.0) = 0.0;

varying vec2 offset;
varying vec3 world_pos_3d;

void vertex()
{
	float rot_y_rad = radians(rot_y_deg);
	float rot_x_rad = radians(rot_x_deg);

	float sin_y = sin(rot_y_rad), cos_y = cos(rot_y_rad);
	float sin_x = sin(rot_x_rad), cos_x = cos(rot_x_rad);

	// Construct rotation matrix
	mat3 rotation_matrix;
	rotation_matrix[0] = vec3(cos_y, 0.0, -sin_y);
	rotation_matrix[1] = vec3(sin_y * sin_x, cos_x, cos_y * sin_x);
	rotation_matrix[2] = vec3(sin_y * cos_x, -sin_x, cos_y * cos_x);

	// Project UV coordinates into pseudo-3D space
	float perspective_scale = tan(radians(fov) * 0.5);
	world_pos_3d = rotation_matrix * vec3(UV - 0.5, 0.5 / perspective_scale);

	// Adjust XY coordinates based on perspective depth
	float depth_scale = (0.5 / perspective_scale) + 0.5;
	world_pos_3d.xy *= depth_scale * rotation_matrix[2].z;
	offset = depth_scale * rotation_matrix[2].xy;

	// Apply perspective transformation to vertex position 
	VERTEX += (UV - 0.5) / TEXTURE_PIXEL_SIZE * perspective_scale * (1.0 - inset);
}

void fragment()
{
	if (cull_backface && world_pos_3d.z <= 0.0)
	{
		discard;
	}

	vec2 projected_uv = (world_pos_3d.xy / world_pos_3d.z) - offset + 0.5;

	if (projected_uv.x < 0.0 || projected_uv.x > 1.0 || projected_uv.y < 0.0 || projected_uv.y > 1.0)
	{
		discard;
	}

	vec2 final_uv = vec2(1.0 - projected_uv.x, projected_uv.y);

	vec2 uv1 = vec2(final_uv.x / 4.0 + 0.0 / 4.0, final_uv.y);
	vec2 uv2 = vec2(final_uv.x / 4.0 + 1.0 / 4.0, final_uv.y);
	vec2 uv3 = vec2(final_uv.x / 4.0 + 2.0 / 4.0, final_uv.y);
	vec2 uv4 = vec2(final_uv.x / 4.0 + 3.0 / 4.0, final_uv.y);

	vec4 tex1 = texture(atlas, uv1);
	vec4 tex2 = texture(atlas, uv2);
	vec4 tex3 = texture(atlas, uv3);
	vec4 tex4 = texture(atlas, uv4);
	
    float blink = 0.5 - sin(TIME * 35.0) * 0.5;
    float invul_factor = blink * float(is_invul);
	vec4 focus_blink = mix(tex2, tex3, blink);

	COLOR = mix(mix(tex1, focus_blink, is_focused), tex4, invul_factor);
}