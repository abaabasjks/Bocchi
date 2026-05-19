class_name PlayerIdleState
extends PlayerState

func init() -> void:
	pass

func enter() -> void:
	player.animation_player.play("idle")
	pass

func exit() -> void:
	pass

func handle_input( _event: InputEvent) -> PlayerState:
	#强调瞬时触发的
	if _event.is_action_pressed("jump"):
		return jump
	return next_state

func process(_delta: float) -> PlayerState:
	#输入检测，动画逻辑，
	if player.direction.x != 0:
		return run
	elif player.direction.y > 0:
		return crouch
	return next_state

func physics_process(_delta: float) -> PlayerState:
	#速度有关的，地面上这种物理有关的，物理检测,碰撞
	player.velocity.x = 0
	if !player.is_on_floor():
		return fall
	return next_state
