shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

uniform sampler2DArray texture_array_albedo : source_color, filter_nearest, repeat_enable;

varying flat int array_index;

void vertex() {
	array_index = int(CUSTOM0.x);
}

void fragment() {
	vec2 base_uv = UV;
	vec3 mod_uv = vec3(base_uv.xy, float(array_index));
	vec4 albedo_tex = texture(texture_array_albedo, mod_uv);
	ALBEDO = albedo_tex.rgb;
}
