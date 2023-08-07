shader_type spatial;

void fragment() {
	float r = mod(floor(FRAGCOORD.x) + floor(FRAGCOORD.y),2);
	if (r == 0.0)
		discard;
}
