shader_type canvas_item;

uniform sampler2D tex : hint_black;
uniform float amount; 
uniform bool smart;

void fragment() {
	
	float xScale = 1.0 / float(textureSize(tex, 0).x) ;
	float yScale = 1.0 / float(textureSize(tex, 0).y) ;
	
	vec4 baseColor = texture(tex,UV);

	vec4 leftColor = texture(tex, UV + vec2(-xScale,0));
	vec4 rightColor = texture(tex, UV + vec2(xScale,0));
	vec4 upColor = texture(tex, UV + vec2(0, -yScale));
	vec4 downColor = texture(tex, UV + vec2(0, yScale));
	
	vec4 averageColor = leftColor + rightColor + upColor + downColor;
	averageColor /= 4.0;
	
	float mixFactor;
	
	if(smart) {
		mixFactor = clamp(1.0 - distance(averageColor, baseColor), 0, 1);
		mixFactor = pow(mixFactor, 3);
		mixFactor *= amount;
	} else {
		mixFactor = amount * 0.7;
	}
	
	COLOR = mix(baseColor, averageColor, mixFactor);

}
