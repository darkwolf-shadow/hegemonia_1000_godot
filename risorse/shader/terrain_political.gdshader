shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform sampler2D heightmap_tex : hint_default_black, filter_linear, repeat_disable;
uniform sampler2D province_id_tex : filter_nearest;

uniform float sea_level : hint_range(0.0, 1.0) = 0.5;

uniform vec4 ocean_color : source_color = vec4(0.08, 0.25, 0.55, 1.0);
uniform vec4 land_base_color : source_color = vec4(0.4, 0.5, 0.3, 1.0);

void vertex() {
	float h = texture(heightmap_tex, UV).r;
	// Stacco netto: terra leggermente rialzata, mare piatto
	if (h > sea_level) {
		VERTEX.y += 0.15;
	} else {
		VERTEX.y = 0.0;
	}
}

void fragment() {
	float h = texture(heightmap_tex, UV).r;
	
	if (h <= sea_level) {
		ALBEDO = ocean_color.rgb;
		ROUGHNESS = 0.2;
		SPECULAR = 0.5;
	} else {
		vec4 prov_color = texture(province_id_tex, UV);
		ALBEDO = mix(land_base_color.rgb, prov_color.rgb, 0.6);
		ROUGHNESS = 0.8;
		
		// Genera la normale dal gradiente della heightmap per le ombre dei rilievi
		vec2 h_pixel = vec2(0.001, 0.0);
		float h_right = texture(heightmap_tex, UV + h_pixel.xy).r;
		float h_up = texture(heightmap_tex, UV + h_pixel.yx).r;
		vec3 normal_map = normalize(vec3((h - h_right) * 10.0, 1.0, (h - h_up) * 10.0));
		NORMAL = NORMAL_MAP_DEPTH > 0.0 ? mix(NORMAL, normal_map, 0.5) : normal_map;
	}
}
