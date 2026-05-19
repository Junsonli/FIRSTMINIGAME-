extends Node

var nav_layer:Nav_layer

func get_grid_position(world_position:Vector2) -> Vector2i:
	return nav_layer.local_to_map(nav_layer.to_local(world_position)) ##世界坐标到局部坐标到网格坐标

func get_world_position(grid_position:Vector2i) -> Vector2:
	return nav_layer.to_global(nav_layer.map_to_local(grid_position)) ##网格坐标到局部坐标到世界坐标

func get_mouse_world_position() -> Vector2:
	return nav_layer.get_global_mouse_position()

func get_mouse_grid_position() -> Vector2i:
	return get_grid_position(get_mouse_world_position())  #把鼠标像素坐标→局部像素→网格，从而知道indirector

func get_nav_grid_path(start_gird_position:Vector2i,end_gird_position:Vector2i) -> Array[Vector2i]:
	if not is_valid_grid(start_gird_position) or not is_valid_grid(end_gird_position):
		return []
	return nav_layer.a_star.get_id_path(start_gird_position,end_gird_position)
	
func get_nav_world_path(start_gird_position:Vector2i,end_gird_position:Vector2i) -> Array[Vector2]:
	var grid_path = get_nav_grid_path(start_gird_position,end_gird_position)
	var world_path:Array[Vector2] = []
	
	for grid_position in grid_path:
		var world_position = get_world_position(grid_position)
		world_path.append(world_position)
	
	return world_path

func is_valid_grid(grid_position:Vector2i) -> bool:
		return nav_layer.grid_data_dict.has(grid_position)

func is_grid_walkable(grid_position:Vector2i) -> bool:
	return is_valid_grid(grid_position) and nav_layer.grid_data_dict[grid_position].walkable

func set_grid_walkable(grid_position:Vector2i,walkable:bool) -> void:
	if not is_valid_grid(grid_position):
		return
	
	nav_layer.grid_data_dict[grid_position].walkable = walkable
	nav_layer.a_star.set_point_solid(grid_position, !walkable)

func is_grid_occupied(grid_position:Vector2i) -> bool: 
	return  is_valid_grid(grid_position) and nav_layer.grid_data_dict[grid_position].is_occupied_by_unit()

func get_grid_occupied(grid_position:Vector2i) -> Unit:
	if not is_valid_grid(grid_position):
		return null
	else:
		return nav_layer.grid_data_dict[grid_position].occupied_unit

func set_grid_occupied(grid_position:Vector2i,unit:Unit) -> void:
	if not is_valid_grid(grid_position):
		return 
	nav_layer.grid_data_dict[grid_position].occupied_unit = unit
