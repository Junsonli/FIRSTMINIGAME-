extends BaseAction
class_name SwordAction


func start_action(target_grid_position:Vector2i,on_action_finished:Callable) -> void:
	super.start_action(target_grid_position,on_action_finished)
	print("Start"+action_name)
	finish_action()
