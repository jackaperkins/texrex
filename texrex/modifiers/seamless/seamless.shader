shader_type canvas_item;

uniform sampler2D tex : hint_black;
uniform sampler2D splatMap;
uniform float distance = 2;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float mapping(float x) {
	float lower = mix(1, 0, clamp(x*distance,0,1));
	float upper = mix(0, 1, clamp((x-(1.0 - 1.0/distance))*distance, 0, 1) );
	return max(lower, upper);
}

float rand_split(float span, vec2 co){
	return rand(co)*2.0*span - span;
}

void fragment() {
	vec4 UVFromSplat =  texture(splatMap, UV);
	
	vec4 baseColor = texture(tex, UV);
	
	vec2 splatUVs = fract(vec2(UVFromSplat.r + UVFromSplat.b, UVFromSplat.g) + fract(UV+vec2(0.5,0.5)));
	splatUVs = vec2(0.2,0.2) + splatUVs * 0.8;
	
	vec4 splatted = texture(tex, splatUVs);
	
	float fader = max(mapping(UV.x), mapping(UV.y));
	baseColor = mix(baseColor, splatted, fader);
//	pixelColor = texture(tex, UV);

	COLOR = baseColor;
}	

