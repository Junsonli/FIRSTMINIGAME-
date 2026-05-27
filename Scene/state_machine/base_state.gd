extends Node

class_name  BaseState

signal state_changed(state_name:String)

@export var state_name:String



func on_state_enter() -> void:
	pass

func on_state_frame_update(delta:float) -> void:
	pass

func on_state_physics_update(delta:float) -> void:
	pass

func on_state_exit() -> void:
	pass
