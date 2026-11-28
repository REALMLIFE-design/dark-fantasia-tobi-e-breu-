shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform sampler2D base_color_texture : source_color, repeat_enable;
uniform sampler2D normal_texture : hint_normal, repeat_enable;
uniform sampler2D roughness_texture : repeat_enable;
uniform sampler2D ao_texture : repeat_enable;
uniform sampler2D metallic_texture : repeat_enable;
uniform sampler2D emission_texture : source_color, repeat_enable;

uniform bool has_base_color_texture = false;
uniform bool has_normal_texture = false;
uniform bool has_roughness_texture = false;
uniform bool has_ao_texture = false;
uniform bool has_metallic_texture = false;
uniform bool has_emission_texture = false;

uniform vec4 base_color : source_color = vec4(0.20, 0.25, 0.20, 1.0);
uniform float base_roughness : hint_range(0.0, 1.0) = 0.90;
uniform float base_metallic : hint_range(0.0, 1.0) = 0.0;
uniform float base_ao : hint_range(0.0, 1.0) = 1.0;
uniform vec3 base_emission = vec3(0.0);
uniform vec3 moss_color = vec3(0.18, 0.28, 0.20);
uniform vec3 cold_tint = vec3(0.94, 0.98, 0.96);
uniform float moss_strength : hint_range(0.0, 0.4) = 0.18;
uniform float moss_scale : hint_range(0.1, 20.0) = 4.0;
uniform float normal_strength : hint_range(0.0, 2.0) = 0.85;
uniform float ao_strength : hint_range(0.0, 1.0) = 0.8;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float value_noise(vec2 p) {
	vec2 cell = floor(p);
	vec2 local = fract(p);
	local = local * local * (3.0 - 2.0 * local);
	float a = hash21(cell);
	float b = hash21(cell + vec2(1.0, 0.0));
	float c = hash21(cell + vec2(0.0, 1.0));
	float d = hash21(cell + vec2(1.0, 1.0));
	return mix(mix(a, b, local.x), mix(c, d, local.x), local.y);
}

void fragment() {
	vec4 base_sample = has_base_color_texture ? texture(base_color_texture, UV) : base_color;
	float roughness_value = has_roughness_texture ? texture(roughness_texture, UV).r : base_roughness;
	float metallic_value = has_metallic_texture ? texture(metallic_texture, UV).r : base_metallic;
	float ao_value = has_ao_texture ? texture(ao_texture, UV).r : base_ao;

	float broad_moss = value_noise(UV * moss_scale);
	float fine_moss = value_noise(UV * moss_scale * 3.1 + vec2(17.0, 9.0));
	float moss_mask = smoothstep(0.56, 0.78, broad_moss) * smoothstep(0.20, 0.68, fine_moss);
	float emission_level = max(max(base_emission.r, base_emission.g), base_emission.b);
	moss_mask *= moss_strength;
	moss_mask *= 1.0 - clamp(metallic_value, 0.0, 1.0);
	moss_mask *= 1.0 - smoothstep(0.03, 0.35, emission_level);

	ALBEDO = mix(base_sample.rgb * cold_tint, moss_color, clamp(moss_mask, 0.0, 1.0));
	ROUGHNESS = mix(roughness_value, max(roughness_value, 0.94), clamp(moss_mask * 0.8, 0.0, 1.0));
	METALLIC = metallic_value;
	AO = mix(1.0, ao_value, ao_strength);
	EMISSION = has_emission_texture ? texture(emission_texture, UV).rgb * base_emission : base_emission;
	if (has_normal_texture) {
		NORMAL_MAP = texture(normal_texture, UV).rgb;
		NORMAL_MAP_DEPTH = normal_strength;
	}
}
