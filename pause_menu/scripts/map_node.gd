@tool
@icon( "res://general/icons/map_node.svg" )

class_name MapNode
extends Control

const SCALE_FACTOR: float = 40

@export_file(".tscn") var linked_scene: String: set = _on_scene_set
#手动刷新，可能上面的场景，场景路径没有变，但是场景本身变了
@export_tool_button("Update") var update_node_action = update_node

@export var entrance_top: Array[float] = []
@export var entrance_right: Array[float] = []
@export var entrance_bottom: Array[float] = []
@export var entrance_left: Array[float] = []

#这个变量是遮挡(传送门)的位置偏移
#每个关卡的基准点是0，0
#但是地图边界可能很大很大(levelbounds的基准点是可能是(100，50))
#然后这个变量记录一下，传送门的位置偏移
var indicator_offset: Vector2 = Vector2.ZERO

@onready var label: Label = $Label
@onready var transition_blocks: Control = %TransitionBlocks

#label是为了更新关卡的名字，
#TransitionBlocks是为了更新，切换出入口

func _ready() -> void:
	if Engine.is_editor_hint():
		#如果现在是编辑状态，那么先什么都不要做
		pass
	else:
		label.queue_free()
		#这里等下要做:关卡切换的小黑方块
		#检查这个地区，是否被玩家发现
		create_transition_blocks()
		if not SaveManager.is_area_discovered( linked_scene ):
			visible = false
		elif SceneManager.current_scene_uid == linked_scene:
			display_player_location()
		pass

func _on_scene_set(_value: String) -> void:
	#更改链接场景的时候会变化
	if linked_scene != _value:
		linked_scene = _value
	if Engine.is_editor_hint():
		update_node()
	pass


#在内存中生成一个链接场景的实例
#就是每个场景都有一个对应的Map_Node，这个Map_Node(记录对应的场景)
#接着在内存中偷偷实例化一个场景出来(玩家看不见)，找到这个内存场景的，关卡边界，关卡范围
#
func update_node() -> void:
	#定义默认视口大小
	var new_size: Vector2 = Vector2(480, 270)
	#定义装载传送门的数组
	var transitions: Array[LevelTransition] = []
	
	if ResourceLoader.exists(linked_scene):
		#转化成PackScene, 作为场景蓝图
		#必须转化成PackedScene，蓝图
		var packed_scene: PackedScene = ResourceLoader.load(linked_scene) as PackedScene
		if packed_scene:
			#生成一个场景实例(但没有加载到场景树上)
			var instance = packed_scene.instantiate()
			if instance:
				#编辑器的状态下
				update_node_label(instance)
				#使用foreach，遍历所有的子节点
				for c in instance.get_children():
					if c is LevelBounds:
						#如果是关卡边界，那么就赋值new_size，准备等比例缩小
						new_size = Vector2(c.width, c.height)
						#记录传送门偏移
						indicator_offset = c.position
					elif c is LevelTransition:
						#传送门的数组，增加
						transitions.append(c)
				instance.queue_free()
	size = new_size / SCALE_FACTOR
	#等比例放缩，同时四舍五入
	size = size.round()
	create_entrance_data(transitions)
	create_transition_blocks()
	pass

#编辑器的状态下，找到场景的路径，接着删掉里面一些，最后把label的值赋上
#在编辑器状态下显示，链接对应的关卡
func update_node_label(scene: Node) -> void:
	if not label:
		label = $Label
	var t: String = scene.scene_file_path
	t = t.replace("res://levels/", "")
	t = t.replace(".tscn", "")
	label.text = t
	pass

func create_entrance_data(transitions: Array[LevelTransition]) -> void:
	entrance_bottom.clear()
	entrance_left.clear()
	entrance_right.clear()
	entrance_top.clear()
	for t in transitions:
		var pos: Vector2 = ( t.position - indicator_offset ) / SCALE_FACTOR
		if t.location == LevelTransition.SIDE.LEFT:
			var offset: float = clampf(
				pos.y - 3,
				2.0, self.size.y - 5
			)
			entrance_left.append( offset )
		elif t.location == LevelTransition.SIDE.RIGHT:
			var offset: float = clampf(
				pos.y - 3,
				2.0, self.size.y - 5
			)
			entrance_right.append( offset )
		elif t.location == LevelTransition.SIDE.TOP:
			var offset: float = clampf(
				pos.x,
				2.0, self.size.x - 5
			)
			entrance_top.append( offset )
		elif t.location == LevelTransition.SIDE.BOTTOM:
			var offset: float = clampf(
				pos.x,
				2.0, self.size.x - 5
			)
			entrance_bottom.append( offset )
	pass

func create_transition_blocks() -> void:
	if not transition_blocks:
		transition_blocks = %TransitionBlocks
	#先全部删掉
	for c in transition_blocks.get_children():
		c.queue_free()
	
	for t in entrance_left:
		var block: ColorRect = add_block()
		block.size.y = 3
		block.position.x = 0
		block.position.y = t
	
	for t in entrance_right:
		var block: ColorRect = add_block()
		block.size.y = 3
		block.position.x = self.size.x - 1
		block.position.y = t
	
	for t in entrance_top:
		var block: ColorRect = add_block()
		block.size.x = 3
		block.position.y = 0
		block.position.x = t
	
	for t in entrance_bottom:
		var block: ColorRect = add_block()
		block.size.x = 3
		block.position.y = self.size.y - 1
		block.position.x = t
	pass

func add_block() -> ColorRect:
	var block: ColorRect = ColorRect.new()
	transition_blocks.add_child( block )
	
	block.custom_minimum_size.x = 1
	block.custom_minimum_size.y = 1
	
	return block

func display_player_location() -> void:
	var player: Player = get_tree().get_first_node_in_group( "Player" )
	var i: Control = %PlayerIndicator
	var pos: Vector2 = position
	pos += ( (player.global_position - indicator_offset) / SCALE_FACTOR )
	var _clamp: Vector2 = Vector2(2, -3)
	pos = pos.clamp(position, position + size - Vector2(5,5))
	i.position = pos
	print("MapNode位置: ", position)
	print("计算出的指示器位置: ", pos)
	print("指示器最终位置: ", i.position)
	pass
