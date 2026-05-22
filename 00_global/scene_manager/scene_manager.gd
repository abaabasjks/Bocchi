extends CanvasLayer

signal load_scene_started
signal new_scene_ready(_target_name: String, offset: Vector2)
signal load_scene_finished

@onready var fade: Control = $Fade


func _ready() -> void:
	fade.visible = false
	await get_tree().process_frame
	load_scene_finished.emit()
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
	
	await get_tree().scene_changed
	
	new_scene_ready.emit(_target_area_name, player_offset)
	
	#fade out
	await fade_screen(Vector2.ZERO, -fade_pos)
	
	fade.visible = false
	get_tree().paused = false
	
	load_scene_finished.emit()
	
	pass

func fade_screen(from: Vector2, to: Vector2) -> Signal:
	fade.position = from
	var tween: Tween = create_tween()
	tween.tween_property(fade, "position", to, 0.2)
	return tween.finished

func get_fade_pos(_dir: String) -> Vector2:
	var pos: Vector2 = Vector2(640*2, 360*2)
	
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
