extends CanvasLayer

#region /// on ready variables
@onready var main_menu: VBoxContainer = %MainMenu
@onready var new_game_menu: VBoxContainer = %NewGameMenu
@onready var load_game_menu: VBoxContainer = %LoadGameMenu

@onready var new_game_button: Button = %NewGameButton
@onready var load_game_button: Button = %LoadGameButton

@onready var new_slot_01: Button = %NewSlot01
@onready var new_slot_02: Button = %NewSlot02
@onready var new_slot_03: Button = %NewSlot03

@onready var load_slot_01: Button = %LoadSlot01
@onready var load_slot_02: Button = %LoadSlot02
@onready var load_slot_03: Button = %LoadSlot03

@onready var animation_player: AnimationPlayer = $Control/MainMenu/Logo/AnimationPlayer
#endregion

func _ready() -> void:
	# 链接按钮信号
	new_game_button.pressed.connect(show_new_game_menu)
	load_game_button.pressed.connect(show_load_game_menu)
	
	new_slot_01.pressed.connect(_on_new_game_pressed.bind(0))
	new_slot_02.pressed.connect(_on_new_game_pressed.bind(1))
	new_slot_03.pressed.connect(_on_new_game_pressed.bind(2))
	
	load_slot_01.pressed.connect(_on_load_game_pressed.bind(0))
	load_slot_02.pressed.connect(_on_load_game_pressed.bind(1))
	load_slot_03.pressed.connect(_on_load_game_pressed.bind(2))
	# 添加按钮音效
	# 展示主菜单
	show_main_menu()
	# 实现Logo动画切换
	animation_player.animation_finished.connect(_on_start_animation_finished)
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if main_menu.visible == false:
			show_main_menu()

func show_main_menu() -> void:
	main_menu.visible = true
	new_game_menu.visible = false
	load_game_menu.visible = false
	new_game_button.grab_focus()
	pass

func show_new_game_menu() -> void:
	main_menu.visible = false
	new_game_menu.visible = true
	load_game_menu.visible = false
	
	new_slot_01.grab_focus()
	
	if SaveManager.save_file_exists(0):
		new_slot_01.text = "替换存档1"
	if SaveManager.save_file_exists(1):
		new_slot_02.text = "替换存档2"
	if SaveManager.save_file_exists(2):
		new_slot_03.text = "替换存档3"
	
	
	pass

func show_load_game_menu() -> void:
	main_menu.visible = false
	new_game_menu.visible = false
	load_game_menu.visible = true
	
	load_slot_01.grab_focus()
	
	load_slot_01.disabled = not SaveManager.save_file_exists(0)
	load_slot_02.disabled = not SaveManager.save_file_exists(1)
	load_slot_03.disabled = not SaveManager.save_file_exists(2)
	
	pass

func _on_new_game_pressed(slot: int) -> void:
	SaveManager.create_new_game_save(slot)
	#SceneManager.transition_scene(
		#"uid://cqabvanatmvp1",
		#"",
		#Vector2.ZERO,
		#"up"
	#)
	pass

func _on_load_game_pressed(slot: int) -> void:
	SaveManager.load_game(slot)

func _on_start_animation_finished(_anim_name: String) -> void:
	#这里是因为有，刚刚结束的动画的名称(感觉不会使用到)
	if _anim_name == "start":
		animation_player.play("loop")
	pass
