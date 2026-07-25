@icon("res://general/icons/input_hints.svg")
class_name InputHints extends Node2D

const HINT_MAP: Dictionary = {
	"keyboard": {
		"interact": 15,
		"attack": 10,
		"jump": 9,
		"dash": 11,
		"up": 13,
	},
	"playstation": {
		"interact": 0,
		"attack": 2,
		"jump": 1,
		"dash": 3,
		"up": 4,
	},
	"xbox": {
		"interact": 8,
		"attack": 7,
		"jump": 5,
		"dash": 6,
		"up": 4,
	}
}

var controller_type: String = "keyboard"

@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	#默认是不可见的
	visible = false
	
	Messages.input_hint_changed.connect(_on_hint_changed)
	pass

func _input(_event: InputEvent) -> void:
	if _event is InputEventMouseButton or _event is InputEventKey:
		controller_type = "keyboard"
	elif _event is InputEventJoypadButton:
		get_controller_type(_event.device)

func get_controller_type(device_id) -> void:
	var n: String = Input.get_joy_name(device_id).to_lower()
	if "xbox" in n:
		controller_type = "xbox"
	elif "playstation" in n or "ps" in n or "dualsense" in n:
		controller_type = "playstation"
	elif "nintendo" in n or "switch" in n:
		controller_type = "xbox"
	else:
		#unknown根本没有对应的图标，会导致游戏崩溃
		controller_type = "playstation"
	#这里直接停用了input，意味着后续不可以更换，操作的设备，键鼠->手柄是不可以的
	set_process_input(false)
	pass

func _on_hint_changed(_hint: String) -> void:
	if _hint == "":
		visible = false
	else:
		sprite_2d.frame = HINT_MAP[controller_type].get(_hint, "0")
		visible = true
	pass
