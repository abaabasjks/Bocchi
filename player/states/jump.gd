class_name PlayerJumpState
extends PlayerState

@export var jump_velocity: float = 450

func init() -> void:
	pass

func enter() -> void:
	#播放动画但是直接暂停
	player.animation_player.play("jump")
	player.animation_player.pause()
	player.add_debug_indicator(Color.GREEN)
	player.velocity.y = -jump_velocity
	pass

func exit() -> void:
	player.add_debug_indicator(Color.YELLOW)
	pass

func handle_input( _event: InputEvent) -> PlayerState:
	if _event.is_action_released("jump"):
		player.velocity.y *= 0.5
		#松开跳跃键，速度变为0.5，并且立刻下落状态
		#但是角色还是会向上飞一点点
		return fall
	return next_state

func process(_delta: float) -> PlayerState:
	set_jump_frame()
	return next_state

func physics_process(_delta: float) -> PlayerState:
	if player.is_on_floor():
		return idle
	elif player.velocity.y >= 0:
		return fall
	player.velocity.x = player.direction.x * player.move_speed
	return next_state

func set_jump_frame() -> void:
	#这里是让角色的Y速度来控制动画播放，
	#按照角色的速度映射到0-0.5上，然后判断这个动画到底要播放哪一帧
	var frame: float = remap(player.velocity.y, -jump_velocity, 0.0, 0.0, 0.5)
	player.animation_player.seek(frame, true)
	pass
