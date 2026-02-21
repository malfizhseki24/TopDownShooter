shader_type canvas_item;

// Hit flash uniforms (used during combat)
uniform float flash_intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Dissolve uniforms (used during death)
uniform sampler2D dissolve_texture;
uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.0;
uniform float burn_size : hint_range(0.0, 0.5) = 0.08;
uniform vec4 burn_color : source_color = vec4(0.6, 0.2, 0.8, 1.0);
uniform float emission_amount : hint_range(0.0, 4.0) = 2.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	// Apply hit flash
	vec4 out_color = mix(tex, flash_color * tex.a, flash_intensity);

	// Apply dissolve (only active when dissolve_amount > 0)
	if (dissolve_amount > 0.001) {
		float noise_sample = texture(dissolve_texture, UV).r;
		float burn_edge = 1.0 - smoothstep(dissolve_amount, dissolve_amount + burn_size, noise_sample);
		vec3 emission = burn_color.rgb * burn_edge * emission_amount;
		float alpha_mask = smoothstep(dissolve_amount - burn_size, dissolve_amount, noise_sample);
		out_color = vec4(max(out_color.rgb, emission), alpha_mask * out_color.a);
	}

	COLOR = out_color;
}
