extends CanvasLayer

signal load_scene_started
signal new_scene_ready(_target_name: String, offset: Vector2)
signal load_scene_finished
signal scene_entered(uid: String)

#总结来说，就是旧场景销毁掉，但是SceneManager会存新场景的名称
#并且会加载新场景，新场景里面找到目标传送门和偏移
@onready var fade: Control = $Fade

var current_scene_uid: String

func _ready() -> void:
	fade.visible = false
	await get_tree().process_frame
	#这里是因为第一个场景不是脚本控制加载的，
	#所以不会链接信号和方法
	load_scene_finished.emit()
	
	#这里是为了解决，一开始current_scene为空值的问题(但是一般正常游玩，不会是空值的())
	var current_scene: String = get_tree().current_scene.scene_file_path
	current_scene_uid = ResourceUID.path_to_uid(current_scene)
	scene_entered.emit( current_scene_uid )
	pass

func transition_scene(_new_scene: String, _target_area_name: String, player_offset: Vector2, _dir: String) -> void:
	
	#在淡入淡出的时候暂停游戏
	get_tree().paused = true
	
	var fade_pos: Vector2 = get_fade_pos(_dir)
	fade.visible = true
	
	load_scene_started.emit()
	
	await fade_screen(fade_pos, Vector2.ZERO)
	
	#fade out
	#这是因为在物理帧调用了这个删除所有的场景(包括碰撞，现在告诉你不允许在物理回调的时候，删除)
	#await get_tree().process_frame
	
	get_tree().change_scene_to_file(_new_scene)
	#这里是把目的的路径转化成UID存储起来
	current_scene_uid = ResourceUID.path_to_uid(_new_scene)
	scene_entered.emit(current_scene_uid)
	
	await get_tree().scene_changed
	
	new_scene_ready.emit(_target_area_name, player_offset)
	
	await get_tree().process_frame
	#fade out
	await fade_screen(Vector2.ZERO, -fade_pos)
	
	fade.visible = false
	get_tree().paused = false
	
	load_scene_finished.emit()
	
	pass

#这里是要等这个事情结束，所以改为返回一个Signal信号
func fade_screen(from: Vector2, to: Vector2) -> Signal:
	fade.position = from
	var tween: Tween = create_tween()
	#修改fade，的position属性，到，to的位置，用时0.2秒
	tween.tween_property(fade, "position", to, 0.2)
	return tween.finished

func get_fade_pos(_dir: String) -> Vector2:
	var pos: Vector2 = Vector2(480*2, 270*2)
	#这里是根据那个传送点的方向，判断这个淡入淡出的方向
	match _dir:
		"left":
			pos *= Vector2(-1, 0)
		"right":
			pos *= Vector2(1, 0)
		"up":
			pos *= Vector2(0, -1)
		"down":
			pos *= Vector2(0, 1)
	return pos
