shader_type spatial;
render_mode unshaded;

uniform sampler2D Texture : source_color;  // モデルのテクスチャ
uniform sampler2D Bayer : source_color;    // 4x4のBayerMatrix画像
uniform float Alpha : hint_range(0.0, 1.0) = 0.5;  // アルファパラメータ (0.0～1.0)

void fragment() {
    float dither = texture(Bayer, FRAGCOORD.xy / 4.0).r;
	vec4 pixel = texture(Texture, UV);
    if (dither > Alpha * pixel.a)
        discard;
    ALBEDO = pixel.rgb;
}
