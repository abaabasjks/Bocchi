extends Node

#1.这是一个全局脚本,所以不需要名字
#2.这个脚本是，所有信号的容器
#3.其他脚本可以在这里发送信号，和监听信号

#采用这条总线的主要目的是为了解耦合
#直接修改Player的hp，就要引用player，这不对劲
#应该是save_point发出治疗信号，player自己决定加不加血
@warning_ignore("unused_signal")
signal player_interacted(player: Player)

@warning_ignore("unused_signal")
signal player_healed(amount: float)

@warning_ignore("unused_signal")
signal input_hint_changed(hint: String)
