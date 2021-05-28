shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D tex : hint_black;
uniform bool invert = false;

void fragment() {
	vec4 pixelColor = texture(tex, UV);
	if (invert) {	
		pixelColor = vec4(1,1,1,1) - pixelColor;
		pixelColor.a = 1.0;
	}
	COLOR = pixelColor;
}	

