shader_type spatial;
render_mode unshaded;

uniform vec3 color : source_color;
uniform float intensity : hint_range(0.0, 1.0) = 1.0;
uniform sampler2D aura : source_color;
uniform sampler2D noize : source_color;

void fragment() {
	float a = texture(aura,UV).r;
	vec2 n_uv = vec2(UV.x + sin(TIME)*0.2,UV.y + TIME*0.2);
	a += texture(noize,n_uv).r * 0.5;
	a = (a * a - 0.5) * intensity;
	ALPHA = clamp(a,0.0,1.0);
	ALBEDO = color;
}
