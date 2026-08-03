@tool
@icon( "res://general/icons/door.svg" )
class_name Door extends Node2D

const DOOR_CRASH_AUDIO = preload("res://general/door_and_switch/door_crash.wav")
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	#链接信号
	for c in get_children():
		if c is Switch:
			c.activated.connect( _on_switch_activated )
			if c.is_open == true:
				_on_switch_is_open()
	#链接到开关代码
	pass


func _on_switch_activated() -> void:
	#Audio playback
	animation_player.play( "open" )
	pass

func _on_switch_is_open() -> void:
	animation_player.play( "opened" )
	pass

#下面两个是工具函数
func _get_configuration_warnings() -> PackedStringArray:
	if _check_for_switch() == false:
		return ["需要一个开关节点"]
	return []

func _check_for_switch() -> bool:
	for c in get_children():
		if c is Switch:
			return true
	return false
