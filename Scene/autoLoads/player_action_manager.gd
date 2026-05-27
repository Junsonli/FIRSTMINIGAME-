extends Node

signal unit_selected(unit:Unit)

var is_performing_action:bool = false
var selected_action:BaseAction 
var selected_unit:Unit


func set_selected_unit(unit:Unit) -> void:
	if is_performing_action:
		return
	if selected_action == unit:
		return
		
	selected_unit = unit
	print(unit.name + "selected")
	set_selected_action(unit.actions_manager.get_action("move_aciton"))

func set_selected_action(action:BaseAction) -> void:
	if is_performing_action:
		return
	if selected_action == action:
		return
	
	print("Select" + action.action_name)
	selected_action = action
	 
	GridManager.visualize_grids(selected_action.get_action_grids(),selected_action.grid_color)

func try_perform_selected_action() -> void:
	if is_performing_action:
		return
	 
	if selected_action == null:
		return
	
	var target_grid_position = GridManager.get_mouse_grid_position()
	if not selected_action.get_action_grids().has(target_grid_position):
		return
	
	is_performing_action = true
	selected_action.start_action(target_grid_position,on_action_finished)
	
func on_action_finished() ->void:
	is_performing_action = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
