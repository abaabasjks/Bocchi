#音频全局脚本

extends Node

#混响的总类
enum REVERB_TYPE{ NONE, SMALL, MEDIUM, LARGE }

#AudioStreamPolyphonic是同时管理多个音频的
#下面五个是Ui的界面，点击，按钮的时候会有的音效
@export var ui_focus_audio: AudioStream
@export var ui_select_audio: AudioStream
@export var ui_cancel_audio: AudioStream
@export var ui_success_audio: AudioStream
@export var ui_error_audio: AudioStream

#控制当前的音轨，是Music1还是Music2
var current_track: int = 0
var music_tweens: Array[ Tween ]
#这是Ui的AudioStreamPolyphonic这个东西
var ui_audio_player: AudioStreamPlaybackPolyphonic

var audio_pool: Array[AudioStreamPlayer2D ]
var audio_index: int = 0

#两个音乐是决定：淡入淡出的
#一个旧的声音慢慢变小，另一个声音慢慢变大
@onready var music_1: AudioStreamPlayer = %Music1
@onready var music_2: AudioStreamPlayer = %Music2
@onready var ui: AudioStreamPlayer = %UI

func _ready() -> void:
	ui.play()
	#获得多声道的播放器控制权
	#赋值给ui_audio_player
	ui_audio_player = ui.get_stream_playback()
	
	#采用硬编码，直接设置这个音效池子的数目为32(绝对够用)
	#就是说，运行游戏(因为是全局脚本)的时候，
	#生成32个AudioStreamPlayer（用来播放声音）
	#这就是对象池
	for i in 32:
		var audio_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		add_child( audio_player )
		audio_player.bus = "SFX"
		audio_pool.append( audio_player )
		pass
	pass

func play_music( audio: AudioStream ) -> void:
	#music的stream设置为传递进来的audio, 然后开始播放
	#处理，当前是music_1还是music_2
	#然后实现淡入淡出
	
	#传递当前的音轨
	var current_player: AudioStreamPlayer = get_music_player( current_track )
	if current_player.stream == audio:
		#如果当前的唱片是传递进来的，
		#比如现在播放music_1，又装备播放music_1,那就直接
		return
	
	#当前音轨的索引+1，如果变成2，重置为0，让下一个音轨，在0和1之间循环
	var next_track: int = wrapi( current_track + 1, 0, 2 )
	var next_player: AudioStreamPlayer = get_music_player( next_track )
	
	next_player.stream = audio
	next_player.play()
	
	#制作淡入淡出的效果
	#先删掉所有的Tween
	#再添加Tween，控制淡入淡出
	for t in music_tweens:
		t.kill()
	
	music_tweens.clear()
	#这里是先暂停所有的tween，再全部删掉，接着淡入淡出
	fade_track_out( current_player )
	fade_track_in( next_player )
	
	current_track = next_track
	
	pass

func set_reverb( type: REVERB_TYPE ) -> void:
	var reverb_fx: AudioEffectReverb = AudioServer.get_bus_effect( 1, 0 )
	if not reverb_fx:
		return
	AudioServer.set_bus_effect_enabled( 1, 0, true )
	match type:
		REVERB_TYPE.NONE:
			AudioServer.set_bus_effect_enabled( 1, 0, false)
		REVERB_TYPE.SMALL:
			reverb_fx.room_size = 0.2
		REVERB_TYPE.MEDIUM:
			reverb_fx.room_size = 0.5
		REVERB_TYPE.LARGE:
			reverb_fx.room_size = 0.8
	pass

#ignore_bool表示这个音效，不进入音效库
func play_spatial_sound( audio: AudioStream, pos: Vector2, ignore_pool: bool = false) -> void:
	if ignore_pool:
		var ap: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		add_child( ap )
		ap.bus = "SFX"
		ap.global_position = pos
		ap.stream = audio
		ap.finished.connect( ap.queue_free )
		ap.play()
	else:
		#去对象池子里面抓一个出来
		#不删除哦
		var ap: AudioStreamPlayer2D = audio_pool[ audio_index ]
		ap.global_position = pos
		ap.stream = audio
		ap.play()
		audio_index = wrap( audio_index + 1, 0, 32)
		pass
	pass

func play_ui_audio(audio: AudioStream) -> void:
	if ui_audio_player:
		#传递一个声音进来，然后播放
		#声音是AudioStream类型的
		ui_audio_player.play_stream( audio )
	pass

#给外部提供方法，
#遍历一遍所有的按钮，然后一次性直接分配完
func setup_button_audio(node: Node) -> void:
	#找所有的名称(*表示不管名字)，类型是Button的东西
	for c in node.find_children("*", "Button"):
		c.pressed.connect( ui_select )
		c.focus_entered.connect( ui_focus_change )
	pass 

#创建五个方法是为了其他地方可以访问
#其他地方调用函数，播放声音
#region /// ui functions


func ui_focus_change() -> void:
	play_ui_audio( ui_focus_audio )
	pass

func ui_select() -> void:
	play_ui_audio( ui_select_audio )
	pass

func ui_cancel() -> void:
	play_ui_audio( ui_cancel_audio )
	pass

func ui_success() -> void:
	play_ui_audio( ui_success_audio )
	pass

func ui_error() -> void:
	play_ui_audio( ui_error_audio )
	pass
#endregion

func get_music_player( i: int ) -> AudioStreamPlayer:
	if i == 0:
		return music_1
	else:
		return music_2

#一个淡出，一个淡入
func fade_track_out( player: AudioStreamPlayer ) -> void:
	var tween: Tween = create_tween()
	music_tweens.append( tween )
	tween.tween_property( player, "volume_linear", 0.0, 1.5)
	#这里是上面慢慢淡出之后，停止播放
	tween.tween_callback( player.stop )
	pass

func fade_track_in( player: AudioStreamPlayer ) -> void:
	var tween: Tween = create_tween()
	music_tweens.append( tween )
	tween.tween_property( player, "volume_linear", 1.0, 1.0)
	pass
