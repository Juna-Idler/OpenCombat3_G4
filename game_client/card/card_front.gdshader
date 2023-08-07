shader_type canvas_item;

uniform sampler2D screen : hint_screen_texture;

void fragment() {
	vec4 c = texture(screen,SCREEN_UV);
	float gray = 0.299*c.r + 0.587*c.g + 0.114*c.b;
	COLOR = vec4((c.r + gray)/2.0,(c.g + gray)/2.0,(c.b + gray)/2.0,1);
}