@icon( "res://general/icons/switch.svg" )
class_name Switch extends Node2D

signal activated 

const DOOR_SWITCH_AUDIO = preload("uid://ecgdbc2omqx8")

var is_open: bool = false

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var area_2d: Area2D = $Area2D

#Godot里面，子节点的ready执行，快于父节点的ready，才没有问题，这么写代码
func _ready() -> void:
	#查找，这个字典里面，如果有door_01,并且值是open，那么就执行if, 如果没有，那就把false加进去
	if SaveManager.persistent_data.get_or_add( unique_name(), "closed" ) == "open":
		set_open()
		#set to open
	else:
		#链接信号
		area_2d.body_entered.connect( _on_player_entered )
		area_2d.body_exited.connect( _on_player_exited )
		pass
	pass

func _on_player_entered(_n: Node2D) -> void:
	#玩家进入这个区域，就在玩家头顶展示，交互信号
	#如果玩家，按下交互按钮，就执行交互之后的结果，
	#玩家离开这个区域，就不在玩家头顶展示
	Messages.input_hint_changed.emit( "interact" )
	Messages.player_interacted.connect( _on_player_interacted )
	pass

func _on_player_exited(_n: Node2D) -> void:
	Messages.input_hint_changed.emit( "" )
	Messages.player_interacted.disconnect( _on_player_interacted )
	pass

func _on_player_interacted( _player: Player) -> void:
	#Audio playback
	#唯一的数据
	SaveManager.persistent_data[ unique_name() ] = "open"
	activated.emit()
	set_open()
	pass

func set_open() -> void:
	#这里是说翻转这个开关
	#设置成灰色
	#删除区域检测(不可交互了)
	is_open = true
	sprite_2d.flip_h = true
	sprite_2d.modulate = Color.GRAY
	area_2d.queue_free()
	pass

func unique_name() -> String:
	var u_name: String = ResourceUID.path_to_uid( owner.scene_file_path )
	u_name += "/" + get_parent().name + "/" + name
	return u_name
