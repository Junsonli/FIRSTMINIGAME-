extends Node2D

class_name Unit

@onready var actions_manager: ActionsManager = $ActionsManager

var is_performing_action:bool = false
var path:Array[Vector2]
var grid_position:Vector2i:
	get:return GridManager.get_grid_position(global_position)

func on_action_finished() -> void:
	is_performing_action = false

func _unhandled_input(event: InputEvent) -> void: 			#用_unhandled_input是防止和UI的输入冲突，UI处理完剩余的输入才到这里
	if is_performing_action:
		return
	if event.is_action_pressed("left_mouse_click"):
		var mouse_grid_position = GridManager.get_mouse_grid_position()            #获取鼠标当前所在的网格坐标
		is_performing_action = true
		actions_manager.get_action("move_action").start_action(mouse_grid_position,on_action_finished)
