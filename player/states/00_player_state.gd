@icon( "res://player/states/state.svg" )
class_name PlayerState 
extends Node

var player: Player
var next_state: PlayerState

#region /// state reference
@onready var idle: PlayerIdleState = %Idle
@onready var run: PlayerRunState = %Run


#endregion

func init() -> void:
	pass

func enter() -> void:
	pass

func exit() -> void:
	pass

func handle_input( _event: InputEvent) -> PlayerState:
	return next_state

func process(_delta: float) -> PlayerState:
	return next_state

func physics_process(_delta: float) -> PlayerState:
	return next_state
