shader_type canvas_item;

uniform vec4 circle_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float anti_alias_width : hint_range(0.0, 1.0) = 0.05;

void fragment() {
    float dist = length(UV - vec2(0.5));
    float alpha = smoothstep(0.5, 0.5 - anti_alias_width, dist);

    COLOR = vec4(circle_color.rgb, circle_color.a * alpha);
}
