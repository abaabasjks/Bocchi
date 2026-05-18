class_name PlayerFallState
extends PlayerState

@export var fall_gravity_mulitplier: float = 1.165
@export var coyote_time: float = 0.4
@export var jump_buffer_time: float = 0.2

var coyote_timer: float = 0
var buffer_timer: float = 0

func init() -> void:
	pass

func enter() -> void:
	player.gravity_mulitplier = fall_gravity_mulitplier
	if player.previous_state == jump:
		coyote_timer = 0
	else: 
		coyote_timer = coyote_time
	pass

func exit() -> void:
	player.gravity_mulitplier = 1.0
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
	return next_state

func physics_process(_delta: float) -> PlayerState:
	if player.is_on_floor():
		player.add_debug_indicator(Color.ALICE_BLUE)
		if buffer_timer > 0:
			return jump
		return idle
	player.velocity.x = player.direction.x * player.move_speed
	return next_state
