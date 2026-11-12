@icon( "res://general/icons/damage_area.svg" )
class_name DamageArea extends Area2D

signal damage_taken( attack_area )

@export var audio: AudioStream

func take_damage( attack_area: AttackArea ) -> void:
	#print( "DAMAGE!!!", attack_area.damage )
	damage_taken.emit( attack_area )
	if audio:
		Audio.play_spatial_sound( audio, global_position )
	pass
