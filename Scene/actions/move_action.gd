extends BaseAction

class_name MoveAction

var path:Array[Vector2]

var move_speed:float = 100

func start_action(target_grid_position:Vector2i,on_action_finished:Callable) -> void:
	super.start_action(target_grid_position,on_action_finished)
	path = GridManager.get_nav_world_path(unit.grid_position,target_grid_position)

func move(target_global_position:Vector2,delta: float) -> void:
	#朝目标平滑移动，move_speed * delta = 这一帧走多少像素（保证和帧率无关） 
	unit.global_position = unit.global_position.move_toward(target_global_position,move_speed * delta)

func _process(delta: float) -> void:
	if not is_active:
		return
	if path and not path.is_empty():        #path不为空才移动
		move(path[0],delta)                 #朝第一个路径点移动
		if unit.global_position == path[0]:      #到了？
			path.remove_at(0)               #擦掉这个点，走下一个         
	else:
		finish_action()
