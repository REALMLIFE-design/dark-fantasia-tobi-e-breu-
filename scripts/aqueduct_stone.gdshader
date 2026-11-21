shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform sampler2D base_color_texture : source_color, repeat_enable;
uniform sampler2D normal_texture : hint_normal, repeat_enable;
uniform sampler2D roughness_texture : repeat_enable;
uniform sampler2D ao_texture : repeat_enable;
uniform float normal_strength : hint_range(0.0, 2.0) = 0.85;
uniform float ao_strength : hint_range(0.0, 1.0) = 0.8;

void fragment() {
	vec4 base_sample = texture(base_color_texture, UV);
	ALBEDO = base_sample.rgb;
	ROUGHNESS = texture(roughness_texture, UV).r;
	AO = mix(1.0, texture(ao_texture, UV).r, ao_strength);
	NORMAL_MAP = texture(normal_texture, UV).rgb;
	NORMAL_MAP_DEPTH = normal_strength;
}
