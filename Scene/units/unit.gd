extends Node2D

class_name Unit
 
@onready var actions_manager: ActionsManager = $ActionsManager

var grid_position:Vector2i:
	get:return GridManager.get_grid_position(global_position)

@export var is_enemy:bool = false
