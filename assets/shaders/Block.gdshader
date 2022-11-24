shader_type canvas_item;

uniform bool enabled;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	
	if (enabled) {
		vec3 avg = vec3(0.3);
		COLOR.rgb = vec3(dot(COLOR.rgb, avg));
	}
}