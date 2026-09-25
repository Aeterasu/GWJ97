shader_type spatial;
render_mode unshaded, depth_draw_opaque;


uniform sampler2D atlas: filter_nearest;
uniform int hFrames = 4;
uniform int vFrames = 1;
uniform float speed = 8.0;
uniform float game_time = 0.0;

varying vec2 v_uv;

void vertex()
{
	vec4 custom = INSTANCE_CUSTOM;
	vec4 color = COLOR;

	float totalFrames = float(hFrames * vFrames);
	float frame = floor(mod((game_time + color.r) * speed, totalFrames));
	float col = mod(frame, float(hFrames));
	float row = floor(frame / float(hFrames));

	vec2 offset = vec2(custom.r, custom.g);
	vec2 size = vec2(custom.b, custom.a);
	vec2 atlasSize = vec2(textureSize(atlas, 0));
	vec2 frameSizeUV = size / atlasSize;
	vec2 offsetUV = offset / atlasSize;

	v_uv = UV * frameSizeUV + offsetUV + vec2(col, row) * frameSizeUV;
	
	VERTEX.z += COLOR.g;
}

void fragment()
{
	vec4 tex = texture(atlas, v_uv);
	
	if (tex.a < 0.5)
	{
		discard;
	}
	
	ALBEDO = tex.rgb;
}