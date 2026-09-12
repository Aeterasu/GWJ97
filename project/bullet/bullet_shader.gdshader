shader_type canvas_item;
render_mode unshaded;

uniform sampler2D atlas: filter_nearest;
uniform int hFrames = 4;
uniform int vFrames = 1;
uniform float speed = 8.0;

varying vec4 custom;

void vertex()
{
    custom = INSTANCE_CUSTOM;
}

void fragment()
{
	int totalFrames = hFrames * vFrames;

	int frame = int((TIME + custom.r) * speed);
	frame = frame % totalFrames;

	int col = frame % hFrames;
	int row = frame / hFrames;

	vec2 frameSize = vec2(1.0 / float(hFrames), 1.0 / float(vFrames));

	vec2 atlasUV = UV * frameSize + vec2(float(col), float(row)) * frameSize;

	vec4 tex = texture(atlas, atlasUV);

	COLOR = tex.rgba;
}