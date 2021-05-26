shader_type canvas_item;

uniform sampler2D tex : hint_black;
uniform float contrast = 1; 
uniform float preBrightness = 0;
uniform float postBrightness = 0;

void fragment() {
	
	vec4 pixelColor = texture(tex, UV);
//   pixelColor.rgb /= pixelColor.a; // we're skipping alpha for now

 	pixelColor.rgb += preBrightness;
	pixelColor.rgb = ((pixelColor.rgb - 0.5f) * max(contrast, 0)) + 0.5f;
 	pixelColor.rgb += postBrightness;

  // Return final pixel color.
//  pixelColor.rgb *= pixelColor.a;
	COLOR = pixelColor;
}

