extends Node

#在这里放置很多的，视觉特效
const DUST_EFFECT = preload("uid://d0oysoc5n5via")

signal camera_shook( streng: float )

#创建，灰尘特效
func _create_dust_effect( pos: Vector2 ) -> DustEffect:
	#创建新的灰尘实例
	var dust: DustEffect = DUST_EFFECT.instantiate()
	add_child( dust )
	dust.global_position = pos
	#添加到场景树里
	#确定位置
	#返回节点
	return dust
	print( "创建灰尘特效" )
	pass


#创建跳跃的灰尘，
func jump_dust( pos: Vector2 ) -> void:
	var dust: DustEffect = _create_dust_effect( pos )
	dust.start( DustEffect.TYPE.JUMP )
	pass


#创建着陆的灰尘
func land_dust( pos: Vector2 ) -> void:
	var dust: DustEffect = _create_dust_effect( pos )
	dust.start( DustEffect.TYPE.LAND )
	pass

#创建击中的灰尘
func hit_dust( pos: Vector2 ) -> void:
	var dust: DustEffect = _create_dust_effect( pos )
	dust.start( DustEffect.TYPE.HIT )
	pass

func hit_particles() -> void:
	
	pass

func camera_shake( strength: float = 1.0 ) -> void:
	camera_shook.emit( strength )
	pass
