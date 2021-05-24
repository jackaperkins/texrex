shader_type canvas_item;

uniform sampler2D tex;

void fragment() {
    COLOR = vec4(mod(UV.x+ TIME,1), UV.y, 0.5, 1.0) + texture(tex, UV);
}