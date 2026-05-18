class_name PlayerCrouchState
extends PlayerState

@export var deceleration_rate: float = 10

func init() -> void:
	pass

func enter() -> void:
	player.collision_stand.disabled = true#不可用
	player.collision_crouch.disabled = false#可用
	player.sprite_2d.scale.y = 0.5#缩放为0.5
	player.sprite_2d.position.y = -8
	pass

func exit() -> void:
	player.collision_stand.disabled = false#可用
	player.collision_crouch.disabled = true#不可用
	player.sprite_2d.scale.y = 1#回复
	player.sprite_2d.position.y = -16
	pass

func handle_input( _event: InputEvent) -> PlayerState:
	if _event.is_action_pressed("jump"):
		if player.one_way_platform_raycast.is_colliding():
			player.position.y += 4#如果这个检测器检测到，就向下压几个像素
			return fall
		return jump
	return next_state

func process(_delta: float) -> PlayerState:
	if player.direction.y <= 0.5:
		return idle
	return next_state

func physics_process(_delta: float) -> PlayerState:
	#从奔跑进入蹲伏的时候，看到慢慢减速平滑
	#而从蹲伏转换出去的时候，是非常灵敏的
	player.velocity.x -= player.velocity.x * deceleration_rate * _delta
	return next_state
