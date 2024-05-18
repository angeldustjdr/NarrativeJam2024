shader_type canvas_item;

uniform float max_blend : hint_range(0,1) = 0.5;
uniform float rotation_offset = 0;
uniform float intensity : hint_range(0, 10);
uniform bool invert = false;
uniform vec2 rel_rect_size = vec2(1024, 600);
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D gradient ;


float distFromCen(vec2 p) {
	return distance(p, vec2(0.5));
}
//rotates by angle radians
vec2 rotate(vec2 p, float angle){
	return vec2(cos(angle)*p.x-sin(angle)*p.y, sin(angle)*p.x + cos(angle)*p.y);
	}

void fragment() {
	vec4 grad = texture(gradient,UV);
	vec4 c = COLOR;
	
	float distMod = invert ? distFromCen(UV) : 0.5 - distFromCen(UV);
	float angle = intensity * distMod * 6.28318 + rotation_offset;
	vec2 newp = rotate(UV-vec2(0.5), angle) + vec2(0.5);
	vec2 disp = (newp - UV) * rel_rect_size * SCREEN_PIXEL_SIZE;
	disp.y = -disp.y; // for some reason UV and SCEEN_UV are inveresed
	COLOR = mix(texture(screen_texture, SCREEN_UV + disp), c, max_blend * 2.0 * (0.5-distFromCen(UV)));
	//COLOR = c;
	//Doesn'[t apply effect outside of circle]
	if (distFromCen(UV) > 0.5) {
		COLOR = texture(screen_texture, SCREEN_UV);
	}
	COLOR.a = grad.a;
}