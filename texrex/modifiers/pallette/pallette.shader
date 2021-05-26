shader_type canvas_item;

uniform sampler2D tex : hint_black;
uniform int count; 

void fragment() {
    COLOR = floor(texture(tex, UV)*float(count)) / float(count);
}



