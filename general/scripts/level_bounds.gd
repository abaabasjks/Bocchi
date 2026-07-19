@tool#编译模式下也能运行
@icon("res://general/icons/level_bounds.svg")
class_name LevelBounds
extends  Node2D

#最小480，最大2048像素，每次间隔都是32个像素，
#这里的suffix是告诉Godot显示的时候要加上后缀
@export_range(480, 2048, 32, "suffix:px") var width: int = 480: set = _on_width_changed
@export_range(270, 2048, 32, "suffix:px") var height: int = 270: set = _on_height_changed

func _ready() -> void:
	# Handle Z-index
	z_index = 256#显示在前面
	if Engine.is_editor_hint():
		return
	
	var camera: Camera2D = null
	#这里的意思是，去找一下相机，没找到就等下一帧渲染完再找一下
	while !camera:
		await get_tree().process_frame
		camera = get_viewport().get_camera_2d()
	
	#限制相机的边界
	# Check for and get reference to our camera
	camera.limit_left = int(global_position.x)
	camera.limit_top = int(global_position.y)
	camera.limit_right = int(global_position.x) + width
	camera.limit_bottom = int(global_position.y) + height
	# Update camera limits
	pass

func _draw() -> void:
	if Engine.is_editor_hint():#如果在编辑器
		# Draw a box
		#这里是让这个矩形框可以自由移动，
		#而不是限定整个世界的(0,0)坐标
		#只不过重合了有误解
		var r: Rect2 = Rect2(Vector2.ZERO, Vector2(width, height))
		draw_rect(r, Color(0.0, 0.45, 1.0, 0.6), false, 3)
		draw_rect(r, Color(0.0, 0.75, 1.0), false, 1)
	pass

func _on_width_changed(_new_width: int) -> void:
	width = _new_width#设置为新值
	queue_redraw()#重新绘制
	pass

func _on_height_changed(_new_height: int) -> void:
	height = _new_height#设置为新值
	queue_redraw()#重新绘制
	pass
