shader_type canvas_item;

uniform sampler2D tex : hint_black;
uniform float amount; 

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
    COLOR = texture(tex, UV) + (rand(UV)*amount - (amount*0.5));
}

