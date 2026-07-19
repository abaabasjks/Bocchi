class_name PlayerFallState
extends PlayerState

@export var fall_gravity_multiplier: float = 1.165
@export var coyote_time: float = 0.4
@export var jump_buffer_time: float = 0.2

#上面是两个预设的时间，下面是两个计时器，每次都把计时器设置为预定时间
var coyote_timer: float = 0
var buffer_timer: float = 0

func init() -> void:
	pass

func enter() -> void:
	player.animation_player.play("jump")
	#播放动画，但是直接按下暂停键
	player.animation_player.pause()
	#这里是为了游戏手感，更快的落下
	player.gravity_multiplier = fall_gravity_multiplier
	#如果之前的状态是跳跃，那么就不设置郊狼时间
	if player.previous_state == jump:
		coyote_timer = 0
	#只有之前状态不是跳跃状态(Idle或者Run),才会启动郊狼时间
	else: 
		coyote_timer = coyote_time
	pass

func exit() -> void:
	player.gravity_multiplier = 1.0
	#防止刚好跳到平台上不受控制的二连跳
	buffer_timer = 0
	pass

func handle_input( _event: InputEvent) -> PlayerState:
	if _event.is_action_pressed("jump"):
		#离开地面一小段时间还可以跳跃
		if coyote_timer > 0:
			return jump
		else:
			buffer_timer = jump_buffer_time
		#在每次按下跳的时候，都重置为0.2
	return next_state

func process(_delta: float) -> PlayerState:
	coyote_timer -= _delta
	buffer_timer -= _delta
	set_jump_frame()
	return next_state

func physics_process(_delta: float) -> PlayerState:
	if player.is_on_floor():
		player.add_debug_indicator(Color.ALICE_BLUE)
		if buffer_timer > 0:
			return jump
		return idle
	player.velocity.x = player.direction.x * player.move_speed
	return next_state

func set_jump_frame() -> void:
	#按照角色的速度映射到0.5-1上，然后判断这个动画到底要播放哪一帧帧
	var frame: float = remap(player.velocity.y, 0.0, player.max_fall_velocity, 0.5, 1.0)
	player.animation_player.seek(frame, true)
	pass
