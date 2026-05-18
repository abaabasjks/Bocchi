class_name PlayerJumpState
extends PlayerState

@export var jump_velocity: float = 450

func init() -> void:
	pass

func enter() -> void:
	player.animation_player.play("jump")
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
	return next_state

func physics_process(_delta: float) -> PlayerState:
	if player.is_on_floor():
		return idle
	elif player.velocity.y >= 0:
		return fall
	player.velocity.x = player.direction.x * player.move_speed
	return next_state
