shader_type canvas_item;
render_mode unshaded;

uniform sampler2D atlas: filter_nearest;

uniform vec2 overlay_offset = vec2(0.0, 0.0);

varying vec4 custom;
varying vec4 instance_color;

void vertex()
{
	custom = INSTANCE_CUSTOM;
	instance_color = COLOR;
}

void fragment()
{
	vec2 offset = vec2(custom.r, custom.g);
	vec2 size = vec2(custom.b, custom.a);

	vec2 atlasSize = vec2(textureSize(atlas, 0));

	vec2 frameSizeUV = size / atlasSize;
	vec2 offsetUV = offset / atlasSize;

	vec2 atlasUV = offsetUV + UV * frameSizeUV;
	vec4 tex = texture(atlas, atlasUV);

	vec2 overlayOffsetUV = overlay_offset / atlasSize;
	vec2 overlayUV = (offsetUV + overlayOffsetUV) + UV * frameSizeUV;
	vec4 overlayTex = texture(atlas, overlayUV);

	vec3 mixedRGB = mix(tex.rgb, overlayTex.rgb, overlayTex.a * instance_color.r);
	float finalAlpha = max(tex.a, overlayTex.a * instance_color.r);

	COLOR = vec4(mixedRGB, finalAlpha);
}