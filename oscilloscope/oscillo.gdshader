shader_type canvas_item;

uniform float freq : hint_range(1.0, 100.0, 1.0) = 25.0;
uniform float ampl : hint_range(0.0, 2.0, 0.05) = 0.5;
uniform float phase : hint_range(0.0, 25.0, 1.0) = 5.0;
uniform float mean : hint_range(-2.0, 2.0, 0.1) = 0.0;
uniform float vel : hint_range(0.0, 25.0, 0.5) = 5.0;
uniform float tightness : hint_range(0.0, 30.0, 0.1) = 20.0;
//uniform bool quality_signal = false;
uniform vec4 modulate : source_color = vec4(0.0, 1.0, 0.0, 1.0);

float random (vec2 uv) {
	return fract(sin(dot(uv.xy,
		vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment()
{
	float wave = sin(UV.x*freq + phase + vel*TIME) * ampl + mean;
	float res2 = abs(2.5 + wave - UV.y * 5.0);
	
	float res = res2;
	
	float color = 1.0 - (res * tightness);
	COLOR =  color * modulate;
}