shader_type canvas_item;
// 定义一个颜色，直接用 vec4的话，是RGBA,4个通道
uniform vec4 blink_color: source_color;
uniform float blink_intensity = 0;

void fragment() {
	//获取原本的颜色
	vec4 color = texture(TEXTURE, UV);
	//插值混合，在color和blink_color里面混合颜色，比例为blink_intensity
	color = mix(color, blink_color, blink_intensity * color.a);
	
	COLOR = color;
}
