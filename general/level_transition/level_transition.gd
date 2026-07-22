@tool
@icon("res://general/icons/level_transition.svg")
class_name LevelTransition
extends Node2D

enum SIDE { LEFT, RIGHT, TOP, BOTTOM }

#范围在2-12，但是可以超出
#每次更改，编辑器会把值给这里接收，然后这里把size的值改成value，同时修改边界
@export_range(2, 12, 1, "or_greater") var size: int = 2:
	set(value):
		size = value
		apply_area_settings()
#这里也是一样，上面更改数目，这里更改方向
@export var location: SIDE = SIDE.BOTTOM:
	set(value):
		location = value
		apply_area_settings()

#这里的*.tscn是限制只可以选择这个后缀的文件
@export_file("*.tscn") var target_level: String = ""
#这里是因为可能有很多个LevelTransition，定位到独属的那个LevelTransition
@export var target_area_name: String = "LevelTransition"

#引用自己下面的Area检测区域
@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	#这里是游戏运行的时候也会执行一次应用检测范围，保险
	apply_area_settings()
	#这里是接听SceneManager的信号，当SceneManager发送这个信号的时候就执行对应的方法
	SceneManager.new_scene_ready.connect(_on_new_scene_ready)
	SceneManager.load_scene_finished.connect(_on_load_scene_finished)

func _on_player_entered(_n: Node2D) -> void:
	#get_tree().change_scene_to_file(target_level)
	#要知道，场景，场景的哪一个LevelTransition，角色偏移，角色的朝向
	SceneManager.transition_scene(target_level, target_area_name, get_offset(_n), get_transition_direction())
	pass

func _on_new_scene_ready(_target_name: String, _offset: Vector2) -> void:
	#position player
	#有很多个tar关卡切换组件都会响应这个方法，所以只让这个目标区域的来执行
	if _target_name == name:#目的地的所有level_transition都会判断这个targrt_name是不是自己
		#找到全局节点Player，增加偏移量
		var player: Node = get_tree().get_first_node_in_group("Player")
		player.global_position = global_position + _offset
	pass

func _on_load_scene_finished() -> void:
	area_2d.monitoring = false
	#这里是因为在加载新的场景的时候，
	#人物的碰撞体会短暂在上一个场景的位置(两帧的时间)
	#所以有可能跳过10，11，12中间的11，在10和12之间切换
	
	#移动到这里是防止奇怪的跳转
	area_2d.body_entered.connect(_on_player_entered)
	#第一帧是给时间完成场景的切换
	#第二帧是安全缓冲
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	area_2d.monitoring = true
	
	pass

func apply_area_settings() -> void:
	area_2d = get_node_or_null("Area2D")
	if !area_2d:
		return
	if location == SIDE.LEFT or location == SIDE.RIGHT:
		area_2d.scale.y = size
		if location == SIDE.LEFT:
			area_2d.scale.x = -1
		else:
			area_2d.scale.x = 1
	else:
		area_2d.scale.x = size
		if location == SIDE.TOP:
			area_2d.scale.y = 1
		else:
			area_2d.scale.y = -1
	pass

func get_offset(player: Node2D) -> Vector2:
	var offset: Vector2 = Vector2.ZERO
	var player_pos: Vector2 = player.global_position
	
	if location == SIDE.LEFT or location == SIDE.RIGHT:
		offset.y = player_pos.y - self.global_position.y
		#玩家的y坐标-自己的全局坐标
		if location == SIDE.LEFT:
			offset.x = -12
		else:
			offset.x = 12
	else:
		offset.x = player_pos.x - self.global_position.x
		if location == SIDE.TOP:
			offset.y = -3
		else:
			offset.y = 45
	return offset

func get_transition_direction() -> String:
	match location:
		SIDE.LEFT:
			return "left"
		SIDE.RIGHT:
			return "right"
		SIDE.TOP:
			return "up"
		_:
			return "down"
