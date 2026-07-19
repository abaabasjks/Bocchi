@icon( "res://player/states/state.svg" )
class_name PlayerState 
extends Node

var player: Player
var next_state: PlayerState

#region /// state reference
@onready var idle: PlayerIdleState = %Idle
@onready var run: PlayerRunState = %Run
@onready var jump: PlayerJumpState = %Jump
@onready var fall: PlayerFallState = %Fall
@onready var crouch: PlayerCrouchState = %Crouch

#endregion

#初始化要做什么，进入这个状态做的准备
func init() -> void:
	pass

#进入这个状态要做什么
func enter() -> void:
	pass

#退出状态要做什么
func exit() -> void:
	pass

#当一个输入被按下要做什么
#InputEvent是所有事件的基类，当有一个事件触发(滑屏，鼠标)，会自己转成具体的子类
func handle_input(_event: InputEvent) -> PlayerState:
	return next_state

#这个状态下动画帧要做什么？
func process(_delta: float) -> PlayerState:
	return next_state

#物理帧要做什么
func physics_process(_delta: float) -> PlayerState:
	return next_state
