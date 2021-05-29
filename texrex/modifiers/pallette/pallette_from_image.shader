shader_type canvas_item;

uniform sampler2D tex : hint_black;
uniform sampler2D sourcePallette : hint_black;



void fragment() {
	vec4 pixel = texture(tex, UV);
	
	float dist = 1000.0;
	vec4 color = vec4(0.0, 0.0, 0.0, 0.0);
	
	for(int i =0; i < 256; i++) {
		vec4 palletteSample = texture(sourcePallette, vec2(float(i%16),float(i/16)) / 16.0);
		float d = distance(pixel, palletteSample);
		if(d < dist) {
			dist = d;
			color = palletteSample;
		}
	}
	
	COLOR = color;
}



