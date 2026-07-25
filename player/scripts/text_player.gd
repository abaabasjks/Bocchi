extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D

func ApplyDamage() -> void:
	var tween = get_tree().create_tween()
	#受击变色
	tween.tween_method(set_shader_blink_intensity, 1.0, 0.0, 0.5)

func set_shader_blink_intensity(_new_value: float) -> void:
	sprite_2d.material.set_shader_parameter("blink_intensity", _new_value)
