shader_type spatial;
render_mode blend_mix, diffuse_burley, specular_schlick_ggx;

uniform vec4 base_tint : source_color = vec4(0.35, 0.43, 0.34, 1.0);
uniform vec4 accent_tint : source_color = vec4(0.20, 0.28, 0.22, 1.0);
uniform float brush_scale = 3.0;
uniform float brush_strength = 0.08;
// 0 painterly base, 1 grass, 2 dirt, 3 swamp/mud, 4 wood, 5 water, 6 snow, 7 roof/brick, 8 cut stone.
uniform int pattern_mode : hint_range(0, 8) = 0;
uniform float detail_scale = 1.0;
uniform float triplanar_sharpness : hint_range(1.0, 12.0) = 4.5;
uniform float bump_strength : hint_range(0.0, 1.0) = 0.16;
uniform sampler2D surface_albedo_atlas : source_color, filter_linear_mipmap, repeat_disable;
uniform sampler2D surface_roughness_atlas : filter_linear_mipmap, repeat_disable;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise_value(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < 4; i++) {
        value += noise_value(p) * amplitude;
        p *= 2.03;
        amplitude *= 0.5;
    }
    return value;
}

vec2 atlas_uv_for(vec2 world_uv, int tile_index) {
    vec2 tile = vec2(float(tile_index % 4), floor(float(tile_index) / 4.0));
    vec2 local_uv = fract(world_uv * max(brush_scale, 0.5) * 0.035);
    local_uv = local_uv * 0.94 + 0.03;
    return (local_uv + tile) / vec2(4.0, 2.0);
}

void fragment() {
    // Fragment VERTEX is view-space; transform back to world-space so textures
    // stay fixed on surfaces while the camera moves.
    vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    vec2 p = world_pos.xz * brush_scale * detail_scale;
    float broad = fbm(p * 0.42);
    float fine = noise_value(p * 3.7);
    float grain = hash(floor(world_pos.xz * brush_scale)) - 0.5;
    float strokes = sin((world_pos.x + world_pos.y * 0.37) * brush_scale * 2.1) * 0.025;
    float pattern = 0.0;
    vec3 tint = base_tint.rgb;

    // Eight compact, hand-painted procedural texture tiles packed into two atlases.
    // 0/8 = stone, 1 = grass, 2 = dirt, 3 = wet mud, 4 = wood,
    // 5 = water, 6 = snow/ice, 7 = roof tiles.
    int tile_index = 7;
    if (pattern_mode == 1) { tile_index = 0; }
    else if (pattern_mode == 2) { tile_index = 1; }
    else if (pattern_mode == 3) { tile_index = 2; }
    else if (pattern_mode == 4) { tile_index = 3; }
    else if (pattern_mode == 5) { tile_index = 4; }
    else if (pattern_mode == 6) { tile_index = 5; }
    else if (pattern_mode == 7) { tile_index = 6; }
    else if (pattern_mode == 8) { tile_index = 7; }
    // Triplanar world mapping prevents stretched XZ projections on cliffs,
    // walls, towers and other vertical geometry while keeping a shared scale.
    vec3 world_normal = normalize(mat3(INV_VIEW_MATRIX) * normalize(NORMAL));
    vec3 tri_weights = pow(abs(world_normal), vec3(triplanar_sharpness));
    tri_weights /= max(dot(tri_weights, vec3(1.0)), 0.0001);
    vec2 uv_x = atlas_uv_for(world_pos.zy, tile_index);
    vec2 uv_y = atlas_uv_for(world_pos.xz, tile_index);
    vec2 uv_z = atlas_uv_for(world_pos.xy, tile_index);
    vec3 atlas_color;
    float atlas_roughness;
    // Most terrain and building faces are axis-aligned: use only two samples
    // there. Reserve full triplanar blending for angled rocks and rounded props.
    if (tri_weights.x > 0.92) {
        atlas_color = texture(surface_albedo_atlas, uv_x).rgb;
        atlas_roughness = texture(surface_roughness_atlas, uv_x).r;
    } else if (tri_weights.y > 0.92) {
        atlas_color = texture(surface_albedo_atlas, uv_y).rgb;
        atlas_roughness = texture(surface_roughness_atlas, uv_y).r;
    } else if (tri_weights.z > 0.92) {
        atlas_color = texture(surface_albedo_atlas, uv_z).rgb;
        atlas_roughness = texture(surface_roughness_atlas, uv_z).r;
    } else {
        atlas_color =
            texture(surface_albedo_atlas, uv_x).rgb * tri_weights.x +
            texture(surface_albedo_atlas, uv_y).rgb * tri_weights.y +
            texture(surface_albedo_atlas, uv_z).rgb * tri_weights.z;
        atlas_roughness =
            texture(surface_roughness_atlas, uv_x).r * tri_weights.x +
            texture(surface_roughness_atlas, uv_y).r * tri_weights.y +
            texture(surface_roughness_atlas, uv_z).r * tri_weights.z;
    }

    if (pattern_mode == 1) { // Grass: soft mottling and short blade-like flecks.
        float blades = smoothstep(0.69, 0.94, noise_value(p * vec2(1.1, 3.8)));
        pattern = (broad - 0.5) * 0.22 + blades * 0.13 + (fine - 0.5) * 0.08;
    } else if (pattern_mode == 2) { // Dirt: granular soil and worn patches.
        float grit = smoothstep(0.58, 0.91, fine);
        pattern = (broad - 0.5) * 0.25 + grit * 0.12;
    } else if (pattern_mode == 3) { // Swamp: dark wet pools and organic mottling.
        float wet = smoothstep(0.43, 0.72, broad);
        tint = mix(base_tint.rgb, accent_tint.rgb, wet * 0.58);
        pattern = (fine - 0.5) * 0.10;
    } else if (pattern_mode == 4) { // Wood: long grain streaks.
        float lines = sin((world_pos.y * 1.8 + world_pos.x * 0.22 + broad) * 22.0);
        pattern = lines * 0.055 + (broad - 0.5) * 0.18;
    } else if (pattern_mode == 5) { // Water: soft flowing ripples.
        float ripple = sin((world_pos.x * 0.7 + sin(world_pos.z * 0.18) * 2.0) * 8.0 + broad * 5.0);
        pattern = ripple * 0.045 + (broad - 0.5) * 0.12;
    } else if (pattern_mode == 6) { // Snow: cool variation and tiny glints.
        float sparkle = smoothstep(0.91, 0.99, fine);
        pattern = (broad - 0.5) * 0.12 + sparkle * 0.16;
    } else if (pattern_mode == 7) { // Roof/brick: irregular bands.
        float courses = sin((world_pos.y * 0.8 + floor(world_pos.x * 1.4) * 0.12) * 9.0);
        pattern = courses * 0.045 + (broad - 0.5) * 0.16;
    } else if (pattern_mode == 8) { // Cut stone: cloudy mineral grain and subtle seams.
        float seams = smoothstep(0.02, 0.075, abs(noise_value(floor(p * 0.55) * 0.73) - 0.5));
        pattern = (broad - 0.5) * 0.20 - (1.0 - seams) * 0.07 + (fine - 0.5) * 0.06;
    } else {
        pattern = grain * brush_strength + strokes + (broad - 0.5) * 0.08;
    }

    ALBEDO = mix(tint, atlas_color, 0.34) * (1.0 + pattern);
    ROUGHNESS = mix(pattern_mode == 5 ? 0.28 : 0.94, atlas_roughness, 0.38);
    METALLIC = pattern_mode == 5 ? 0.12 : 0.0;

    // Derivative-based bump detail reuses the atlas without another texture
    // binding or a tangent-space normal texture, keeping Android memory low.
    float relief = dot(atlas_color, vec3(0.299, 0.587, 0.114)) * 0.72 + broad * 0.28;
    vec3 dpdx = dFdx(VERTEX);
    vec3 dpdy = dFdy(VERTEX);
    vec3 view_normal = normalize(NORMAL);
    vec3 r1 = cross(dpdy, view_normal);
    vec3 r2 = cross(view_normal, dpdx);
    float determinant = dot(dpdx, r1);
    vec3 relief_gradient = sign(determinant) * (dFdx(relief) * r1 + dFdy(relief) * r2);
    NORMAL = normalize(abs(determinant) * view_normal - relief_gradient * bump_strength);
    ALPHA = base_tint.a;
}
