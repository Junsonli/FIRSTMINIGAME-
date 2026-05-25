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
			GridManager.visualize_grids(PlayerActionManager.selected_action.get_action_grids(),PlayerActionManager.selected_action.grid_color)   
			path.remove_at(0)               #擦掉这个点，走下一个    
	else:
		finish_action()

func get_action_grids(unit_grid:Vector2i = unit.grid_position) -> Array[Vector2i]:
	var results:Array[Vector2i] = []
	var max_length = 3
	
	for i in range(-max_length,max_length +1):
		for j in range(-max_length,max_length +1):
			if i ==0 and j == 0:
				continue
			var potential_grid:Vector2i = unit_grid + Vector2i(i,j)
			var grid_path = GridManager.get_nav_grid_path(unit_grid,potential_grid)
			var length = GridManager.get_grid_path_length(grid_path)
			if length <= max_length and length > 0 and GridManager.is_grid_walkable(potential_grid):
				results.append(potential_grid)
	return results
 
