class_name Player
extends CharacterBody2D

const DEBUG_JUMP_INDICATOR = preload("uid://bh5w0awpjg4w7")

#region /// On Ready Variables
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_stand: CollisionShape2D = $CollisionStand
@onready var collision_crouch: CollisionShape2D = $CollisionCrouch
@onready var one_way_platform_raycast: RayCast2D = $OneWayPlatformRaycast

#endregion 

#region /// Export Variables
@export var move_speed: float = 100
#endregion

#region /// State Machine Variables
var states: Array[PlayerState]#状态栈
var current_state: PlayerState:#当前状态
	get: return states.front()#要获取的时候直接返回数组的第一个
var previous_state: PlayerState:#先前状态
	get: return states[1]#要获取的时候直接返回数组的第二个
#endregion

#region /// Standard Variables
var direction: Vector2 = Vector2.ZERO
var gravity: float = 980
var gravity_mulitplier: float = 1.0
#endregion

func _ready() -> void:
	#初始化数组和所有状态
	initialize_states()
	pass

func _unhandled_input(event: InputEvent) -> void:
	change_state(current_state.handle_input(event))
	pass

func _process(_delta: float) -> void:
	update_direction()
	change_state(current_state.process(_delta))
	pass

func _physics_process(_delta: float) -> void:
	velocity.y += gravity * _delta * gravity_mulitplier
	move_and_slide()
	change_state(current_state.physics_process(_delta))
	pass

func initialize_states() -> void:
	states = []
	#收集所有状态
	for c in $States.get_children():
		if c is PlayerState:
			states.append(c)
			c.player = self
		pass
	
	if states.size() == 0:
		return
	
	#初始化所有状态
	for state in states:
		state.init()
	
	#切换到现在这个状态并触发他的enter
	change_state(current_state)
	current_state.enter()
	$Label.text = current_state.name
	#建立我们的第一个状态
	pass

func change_state(new_state: PlayerState) -> void:
	if new_state == null:
		return
	elif new_state == current_state:
		return
	
	if current_state:
		current_state.exit()
	
	#把新状态放到最前面，变成当前状态
	states.push_front(new_state)
	current_state.enter()
	states.resize(3)
	$Label.text = current_state.name
	pass

func update_direction() -> void:#更新方向
	var prev_direction: Vector2 = direction
	
	#direction = Input.get_vector("left", "right", "up", "down")
	var x_axis = Input.get_axis("left", "right")#区别在于在输入映射的时候会剔除0.2(死区)
	var y_axis = Input.get_axis("up", "down")
	direction = Vector2(x_axis, y_axis)
	
	pass
func add_debug_indicator(color: Color = Color.RED) -> void:
	var d: Node2D = DEBUG_JUMP_INDICATOR.instantiate()
	get_tree().root.add_child(d)
	d.global_position = global_position
	d.modulate = color
	await get_tree().create_timer(3).timeout
	d.queue_free()
	pass
