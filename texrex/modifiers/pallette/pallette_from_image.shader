shader_type canvas_item;

uniform sampler2D tex : hint_black;
uniform sampler2D sourcePallette : hint_black;

void fragment() {
	vec4 pixel = texture(tex, UV);
	
	float dist = 1000.0;
	vec4 color = vec4(0.0, 0.0, 0.0, 0.0);
	
	ivec2 dimensions = textureSize(sourcePallette, 0);
	int totalLength = dimensions.x*dimensions.y;
	
	for(int i =0; i < totalLength; i++) {
		vec4 palletteSample = texture(sourcePallette, vec2(float(i%dimensions.x),float(i/dimensions.x)) / vec2(float(dimensions.x),float(dimensions.y)));
		float d = distance(pixel, palletteSample);
		if(d < dist) {
			dist = d;
			color = palletteSample;
		}
	}
	
	COLOR = color;
}



