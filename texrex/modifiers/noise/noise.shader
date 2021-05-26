shader_type canvas_item;

uniform int mode = 1;
uniform sampler2D tex : hint_black;
uniform float amount; 

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec4 hue_shift (vec3 input_color, float shift){

// VectorFunc:2
	vec3 color_hsv;
	{
		vec3 c = input_color;
		vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
		vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
		vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
		float d = q.x - min(q.w, q.y);
		float e = 1.0e-10;
		color_hsv=vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
	}

	color_hsv.x = mod((color_hsv.x + shift), 1.0f);

// VectorFunc:5
	vec3 color_rgb;
	{
		vec3 c = color_hsv;
		vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
		vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
		color_rgb=c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
	}

// Output:0
	return vec4(color_rgb.rgb,1);
}

void fragment() {
	switch(mode){
		case 0: // full brightness mod
		    COLOR = texture(tex, UV) + (rand(UV)*amount - (amount*0.5));
			break;
		case 1: // hue shift
//			COLOR = vec4(1,0,1,1);
   			COLOR = hue_shift(texture(tex, UV).rgb, rand(UV)*amount - (amount*0.5));
			break;
	}
}
