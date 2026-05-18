class_name PlayerFallState
extends PlayerState

@export var coyote_time: float = 0.4
var coyote_timer: float = 0

func init() -> void:
	pass

func enter() -> void:
	coyote_timer = coyote_time
	pass

func exit() -> void:
	pass

func handle_input( _event: InputEvent) -> PlayerState:
	return next_state

func process(_delta: float) -> PlayerState:
	return next_state

func physics_process(_delta: float) -> PlayerState:
	if player.is_on_floor():
		player.add_debug_indicator(Color.ALICE_BLUE)
		return idle
	player.velocity.x = player.direction.x * player.move_speed
	return next_state
