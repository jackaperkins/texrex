shader_type canvas_item;

uniform sampler2D tex : hint_black;
uniform int count; 
uniform int resolution_scale = 1;

uniform bool dither = false;

int dithering_pattern(ivec2 fragcoord) {
	const int pattern[] = {
		-4, +0, -3, +1, 
		+2, -2, +3, -1, 
		-3, +1, -4, +0, 
		+3, -1, +2, -2
	};
	
	int x = fragcoord.x % 4;
	int y = fragcoord.y % 4;
	
	return pattern[y * 4 + x];
}

void fragment() {

	if (!dither) {
		COLOR = floor(texture(tex, UV)*float(count)) / float(count);

	} else {
	
		ivec2 uv = ivec2(FRAGCOORD.xy / float(resolution_scale));
		vec3 color = texelFetch(tex, uv * resolution_scale, 0).rgb;
		
		// Convert from [0.0, 1.0] range to [0, 255] range
		ivec3 c = ivec3(round(color * 255.0));
		
		// Apply the dithering pattern

		c += ivec3(dithering_pattern(uv));

		
		// Truncate from 8 bits to color_depth bits
		c >>= (8 - count);

		// Convert back to [0.0, 1.0] range
		COLOR = vec4(vec3(c) / float(1 << count),1);
	}
}



