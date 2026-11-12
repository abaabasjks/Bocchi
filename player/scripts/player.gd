class_name Player
extends CharacterBody2D

const DEBUG_JUMP_INDICATOR = preload("uid://bh5w0awpjg4w7")

#一些需要的节点
#region /// On Ready Variables
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_stand: CollisionShape2D = $CollisionStand
@onready var collision_crouch: CollisionShape2D = $CollisionCrouch
@onready var one_way_platform_shape_cast_2d: ShapeCast2D = $OneWayPlatformShapeCast2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_area: AttackArea = %AttackArea

#endregion 

#显示，可以调整的数值
#region /// Export Variables
@export var move_speed: float = 100
@export var max_fall_velocity: float = 500
#endregion

#状态栈维护一个数组，提供当前状态和上个状态
#region /// State Machine Variables
var states: Array[PlayerState]#状态栈
var current_state: PlayerState:#当前状态
	get: return states.front()#要获取的时候直接返回数组的第一个
var previous_state: PlayerState:#先前状态
	get: return states[1]#要获取的时候直接返回数组的第二个
#endregion

#角色的数据
#region /// player stats
#很厉害的想法，直接在，当hp和max_hp修改的时候，发送信号
#而不是写一个方法
var hp: float = 20:
	set(value):
		hp = clampf(value, 0, max_hp)
		Messages.player_health_changed.emit(hp, max_hp)
var max_hp: float = 20:
	set(value):
		max_hp = value
		Messages.player_health_changed.emit(hp, max_hp)
var dash: bool = false
var double_jump: bool = false
var ground_slam: bool = false
var morph_roll: bool = false
#endregion

#常量
#region /// Standard Variables
var direction: Vector2 = Vector2.ZERO
var gravity: float = 980
var gravity_multiplier: float = 1.0
#endregion

func _ready() -> void:
	#初始化数组和所有状态
	if get_tree().get_first_node_in_group("Player") != self:
		self.queue_free()
	initialize_states()
	#这里是安排到全局根节点，防止切换场景的时候一起销毁
	self.call_deferred("reparent", get_tree().root)
	
	Messages.player_healed.connect(_on_player_healed)
	Messages.back_to_title_screen.connect( queue_free )
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("action"):
		Messages.player_interacted.emit(self)
	elif event.is_action_pressed("pause"):
		get_tree().paused = true
		#每次都实例化生成一个场景，说明每次都是会执行ready的
		var pause_menu: PauseMenu = load("res://pause_menu/pause_menu.tscn").instantiate()
		add_child(pause_menu)
		return
	if event.is_action_pressed( "attack" ):
		attack_area.activate()
		return
	
	#if event is InputEventKey and event.pressed:
		#if event.keycode == KEY_MINUS:
			#if Input.is_key_pressed(KEY_SHIFT):
				#max_hp -= 2
			#else:
				#hp -= 2
		#elif event.keycode == KEY_EQUAL:
			#if Input.is_key_pressed(KEY_SHIFT):
				#max_hp += 2
			#else:
				#hp += 2
	
	change_state(current_state.handle_input(event))

	pass

func _process(_delta: float) -> void:
	update_direction()
	change_state(current_state.process(_delta))
	pass

func _physics_process(_delta: float) -> void:
	velocity.y += gravity * _delta * gravity_multiplier
	#这里是限制角色的速度
	velocity.y = clampf(velocity.y, -1000, max_fall_velocity)
	move_and_slide()
	change_state(current_state.physics_process(_delta))
	pass

func initialize_states() -> void:
	states = []
	#收集所有状态
	for c in $States.get_children():
		if c is PlayerState:
			states.append(c)
			#每一个状态的player都指向这个Player
			c.player = self
		pass
	
	if states.size() == 0:
		return
	
	#初始化所有状态
	for state in states:
		state.init()
	
	#切换到现在这个状态并触发他的enter
	change_state(current_state)
	#这里又调用一次是因为在执行change_state的时候没有初始化完成，执行了一个空的
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
	
	var x_axis = Input.get_axis("left", "right")#区别在于在输入映射的时候会剔除0.2(死区)
	var y_axis = Input.get_axis("up", "down")
	direction = Vector2(x_axis, y_axis)
	#翻转角色
	#每一帧都在检测
	#这里有两个方向，现在的和之前的，
	#如果现在方向和之前的不一样就表示需要翻转
	if prev_direction.x != direction.x:
		print("翻转")
		attack_area.flip( direction.x )
		print("完成")
		if direction.x < 0: 
			sprite_2d.flip_h = true
		elif direction.x > 0:
			sprite_2d.flip_h = false
	pass

func add_debug_indicator(color: Color = Color.RED) -> void:
	var d: Node2D = DEBUG_JUMP_INDICATOR.instantiate()
	get_tree().root.add_child(d)
	d.global_position = global_position
	#modulate是节点的颜色调制，这个对象的颜色，默认是红色的
	d.modulate = color
	await get_tree().create_timer(3).timeout
	d.queue_free()
	pass

func _on_player_healed(amount: float) -> void:
	hp += amount
	
	pass
