# PlayerHud


#想一下，这里需要更新max_hp， 
#所以需要引用这个container，让总血条看起来变长

#也需要更新，当前血量占总血量的百分比，所以需要这个HpBar
extends CanvasLayer

@onready var hp_margin_container: MarginContainer = %HpMarginContainer
@onready var hp_bar: TextureProgressBar = %HpBar


func _ready() -> void:
	
	Messages.player_health_changed.connect(update_health_bar)
	pass

func update_health_bar(_hp: float, _max_hp: float) -> void:
	
	var value: float = (_hp / _max_hp) * 100
	hp_bar.value = value
	
	#这里加上22是因为：除开这个_max_hp，还有22像素的装饰
	hp_margin_container.size.x = _max_hp + 22
	pass
