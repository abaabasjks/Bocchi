class_name PlayerJumpState
extends PlayerState

@export var jump_velocity: float = 450

func init() -> void:
	pass

func enter() -> void:
	#播放动画但是直接暂停
	player.animation_player.play("jump")
	player.animation_player.pause()
	#进入的时候就调用player的debug方法，并把颜色传递过去
	player.add_debug_indicator(Color.GREEN)
	player.velocity.y = -jump_velocity
	
	#玩家从高处落下，快落地时提前按了一下跳跃键（触发了跳跃缓冲）。
	#玩家落地了，系统立刻把状态切到了 Jump（准备起跳）。
	#但是，玩家按跳跃键的时间非常短，在状态刚切到 Jump 的瞬间，玩家的手指已经松开了。
	#就会导致每一次都跳到最高(但其实不想跳这么高)
	if player.previous_state == fall and !Input.is_action_pressed("jump"):
		await get_tree().physics_frame
		player.velocity.y *= 0.5
		player.change_state(fall)
		pass
	
	pass

func exit() -> void:
	player.add_debug_indicator(Color.YELLOW)
	#退出的时候就调用player的debug方法，并把颜色传递过去
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
	#这里是实现了空中控制角色的左右移动
	player.velocity.x = player.direction.x * player.move_speed
	return next_state

func set_jump_frame() -> void:
	#这里是让角色的Y速度来控制动画播放，
	#按照角色的速度映射到0-0.5上，然后判断这个动画到底要播放哪一帧
	#手动调节
	var frame: float = remap(player.velocity.y, -jump_velocity, 0.0, 0.0, 0.5)
	player.animation_player.seek(frame, true)
	pass
