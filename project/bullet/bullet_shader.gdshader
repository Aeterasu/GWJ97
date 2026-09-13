shader_type canvas_item;
render_mode unshaded;

uniform sampler2D atlas: filter_nearest;
uniform int hFrames = 4;
uniform int vFrames = 1;
uniform float speed = 8.0;

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
	
	int totalFrames = hFrames * vFrames;

	int frame = int((TIME + instance_color.r) * speed);
	frame = frame % totalFrames;

	int col = frame % hFrames;
	int row = frame / hFrames;

	vec2 atlasSize = vec2(textureSize(atlas, 0));

	vec2 frameSizeUV = size / atlasSize;
	vec2 offsetUV = offset / atlasSize;

	vec2 atlasUV = offsetUV + UV * frameSizeUV + vec2(float(col), float(row)) * frameSizeUV;

	vec4 tex = texture(atlas, atlasUV);

	COLOR = tex.rgba;
}