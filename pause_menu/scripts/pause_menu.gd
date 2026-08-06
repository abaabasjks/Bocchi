class_name PauseMenu
extends CanvasLayer

#region /// 需要的变量
@onready var pause_screen: Control = %PauseScreen
@onready var system: Control = %System

@onready var system_menu_button: Button = %SystemMenuButton

@onready var back_to_map_button: Button = %BackToMapButton
@onready var back_to_title_button: Button = %BackToTitleButton
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var ui_slider: HSlider = %UISlider
#endregion

var player_position: Vector2


func _ready() -> void:
	#抓住玩家
	#展示暂停界面
	show_pause_screen()
	system_menu_button.pressed.connect(show_system_menu)
	#音频设置
	Audio.setup_button_audio( self )
	#系统设置
	setup_system_menu()
	var player: Node2D = get_tree().get_first_node_in_group( "Player" )
	if player:
		player_position = player.global_position
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		#告诉引擎，这个事情我已经处理了， 后续的对象不要处理了
		get_viewport().set_input_as_handled()
		get_tree().paused = false
		queue_free()
	if pause_screen.visible == true:
		if event.is_action_pressed("right") or event.is_action_pressed("down"):
			system_menu_button.grab_focus()
	pass

func show_pause_screen() -> void:
	pause_screen.visible = true
	system.visible = false
	pass

func show_system_menu() -> void:
	pause_screen.visible = false
	system.visible = true
	back_to_map_button.grab_focus()
	pass

func setup_system_menu():
	music_slider.value = AudioServer.get_bus_volume_linear( 2 )
	sfx_slider.value = AudioServer.get_bus_volume_linear( 3 )
	ui_slider.value = AudioServer.get_bus_volume_linear( 4 )
	
	music_slider.value_changed.connect( _on_music_slider_changed )
	sfx_slider.value_changed.connect( _on_sfx_slider_changed )
	ui_slider.value_changed.connect( _on_ui_slider_changed )
	
	back_to_title_button.pressed.connect(_on_back_to_title_pressed)
	back_to_map_button.pressed.connect(show_pause_screen)
	pass

func _on_back_to_title_pressed() -> void:
	SceneManager.transition_scene("res://title_screen/title_screen.tscn", "", Vector2.ZERO, "up")
	get_tree().paused = false
	Messages.back_to_title_screen.emit()
	queue_free()
	pass

func _on_music_slider_changed( v: float ) -> void:
	AudioServer.set_bus_volume_linear( 2, v)
	SaveManager.save_configuration()
	#保存到默认设置
	pass

func _on_sfx_slider_changed( v: float ) -> void:
	AudioServer.set_bus_volume_linear( 3, v)
	Audio.play_spatial_sound( Audio.ui_focus_audio, player_position )
	#保存到默认设置
	SaveManager.save_configuration()
	pass

func _on_ui_slider_changed( v: float ) -> void:
	AudioServer.set_bus_volume_linear( 4, v)
	#播放ui的音效
	Audio.ui_focus_change()
	#保存到默认设置
	SaveManager.save_configuration()
	pass
