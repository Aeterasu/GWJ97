shader_type canvas_item;
render_mode blend_add;

group_uniforms Colors;
uniform vec4 color_dark : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 color_light : source_color = vec4(1.0, 1.0, 1.0, 1.0);

group_uniforms Noise;
uniform float grain_size : hint_range(1.0, 2000.0) = 400.0;
uniform float speed : hint_range(0.0, 60.0) = 24.0;
uniform float contrast : hint_range(0.0, 4.0) = 1.0;
uniform float brightness : hint_range(-1.0, 1.0) = 0.0;

group_uniforms Effects;
uniform bool scanlines = true;
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.15;
uniform float scanline_count : hint_range(50.0, 2000.0) = 480.0;
uniform bool roll_bars = false;
uniform float roll_speed : hint_range(-5.0, 5.0) = 0.3;
uniform float roll_bar_count : hint_range(1.0, 20.0) = 3.0;
uniform float opacity : hint_range(0.0, 1.0) = 1.0;

float random(vec3 p) {
	return fract(sin(dot(p, vec3(12.9898, 78.233, 45.164))) * 43758.5453123);
}

void fragment()
{
	float frame_time = floor(TIME * speed);

	vec2 noise_uv = floor(UV * grain_size);
	float n = random(vec3(noise_uv, frame_time));

	n = clamp((n - 0.5) * contrast + 0.5 + brightness, 0.0, 1.0);

	vec4 static_color = mix(color_dark, color_light, n);

	if (scanlines)
	{
		float line = sin(UV.y * scanline_count * PI);
		static_color.rgb -= scanline_strength * (0.5 + 0.5 * line);
	}

	if (roll_bars)
	{
		float bar = sin((UV.y + TIME * roll_speed) * roll_bar_count * TAU);
		static_color.rgb += bar * 0.05;
	}

	static_color.a *= opacity;

	COLOR = static_color;
}