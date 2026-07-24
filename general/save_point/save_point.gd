@icon("res://general/icons/save_point.svg")
class_name SavePoint extends Node2D

@onready var animation_player: AnimationPlayer = $Node2D/AnimationPlayer
@onready var area_2d: Area2D = $Area2D

#链接信号
#在玩家进入的时候持续监听，有没有按下Action键
#在玩家离开的时候放弃监听
func _ready() -> void:
	area_2d.body_entered.connect(_on_player_entered)
	area_2d.body_exited.connect(_on_player_exited)
	pass


func _on_player_entered(_n: Node2D) -> void:
	Messages.player_interacted.connect(_on_player_interacted)
	Messages.input_hint_changed.emit("interact")

func _on_player_exited(_n: Node2D) -> void:
	Messages.player_interacted.disconnect(_on_player_interacted)
	Messages.input_hint_changed.emit("")

func _on_player_interacted(player: Player) -> void:
	print("这是")
	#这里要保存游戏
	#治疗玩家
	#加入动画
	#加入音效
	SaveManager.save_game()
	
	animation_player.play("game_saved")
	animation_player.seek(0)
	
	Messages.player_healed.emit(999)
	pass
