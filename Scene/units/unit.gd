extends Node2D

class_name Unit
 
@onready var actions_manager: ActionsManager = $ActionsManager
@onready var unit_area: Area2D = $UnitArea

@export var is_enemy:bool = false

var grid_position:Vector2i: 
	get:return GridManager.get_grid_position(global_position)

func _ready() -> void:
	unit_area.unit_selected.connect(on_unit_selected)
	GameManager.register_unit(self)

func on_unit_selected() -> void:
	PlayerActionManager.set_selected_unit(self)
