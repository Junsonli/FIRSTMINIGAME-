extends Node

var nav_layer:Nav_layer
var visual_layer:TileMapLayer

func get_grid_position(world_position:Vector2) -> Vector2i:
	return nav_layer.local_to_map(nav_layer.to_local(world_position)) ##世界坐标→局部坐标→网格坐标

func get_world_position(grid_position:Vector2i) -> Vector2:
	return nav_layer.to_global(nav_layer.map_to_local(grid_position)) ##网格坐标→局部坐标→世界坐标

func get_mouse_world_position() -> Vector2:
	return nav_layer.get_global_mouse_position()

func get_mouse_grid_position() -> Vector2i:
	return get_grid_position(get_mouse_world_position())  #鼠标像素→局部像素→网格坐标，用于GridIndicator定位

func get_nav_grid_path(start_gird_position:Vector2i,end_gird_position:Vector2i) -> Array[Vector2i]:
	#如果起点"或"终点有一个不在地图内，返回空数组（or不是and）
	if not is_valid_grid(start_gird_position) or not is_valid_grid(end_gird_position):
		return []
	#两个点都合法时，调用A*计算最短路径（自动绕开solid墙）
	var start_grid_solid: bool = nav_layer.a_star.is_point_solid(start_gird_position)
	nav_layer.a_star.set_point_solid(start_gird_position, false)          # ← 临时打开起点
	var path: Array[Vector2i] = nav_layer.a_star.get_id_path(start_gird_position, end_gird_position)
	nav_layer.a_star.set_point_solid(start_gird_position, start_grid_solid)  # ← 恢复
	return path
	
func get_nav_world_path(start_gird_position:Vector2i,end_gird_position:Vector2i) -> Array[Vector2]:
	var grid_path = get_nav_grid_path(start_gird_position,end_gird_position)
	var world_path:Array[Vector2] = []
	
	for grid_position in grid_path:
		var world_position = get_world_position(grid_position)
		world_path.append(world_position)
	
	return world_path

func is_valid_grid(grid_position:Vector2i) -> bool:
		return nav_layer.grid_data_dict.has(grid_position)            #这格在已绘制区域内吗？

func is_grid_walkable(grid_position:Vector2i) -> bool:
	return is_valid_grid(grid_position) and nav_layer.grid_data_dict[grid_position].walkable            #这格能走吗？（先检查存在，再看walkable）

func set_grid_walkable(grid_position:Vector2i,walkable:bool) -> void:
	#动态修改格子通行状态（比如门打开了），同时同步更新A*障碍
	if not is_valid_grid(grid_position):
		return
	
	nav_layer.grid_data_dict[grid_position].walkable = walkable
	nav_layer.a_star.set_point_solid(grid_position, !walkable)

func is_grid_occupied(grid_position:Vector2i) -> bool:             #这格被单位占了吗？
	return  is_valid_grid(grid_position) and nav_layer.grid_data_dict[grid_position].is_occupied_by_unit()

func get_grid_occupied(grid_position:Vector2i) -> Unit:            #返回占这格的单位（null=没人）
	if not is_valid_grid(grid_position):
		return null
	else:
		return nav_layer.grid_data_dict[grid_position].occupied_unit

func set_grid_occupied(grid_position:Vector2i,unit:Unit) -> void:            #让某个单位占/清空这格（角色移动时调用）
	if not is_valid_grid(grid_position):
		return 
	nav_layer.grid_data_dict[grid_position].occupied_unit = unit

func get_grid_path_length(grid_path:Array[Vector2i]) -> float:
	if grid_path.size() <= 1:
		return 0
	var length:float = 0
	for i in range(1, grid_path.size()):
		if grid_path[i - 1].x != grid_path[i].x and grid_path[i - 1].y != grid_path[i].y:
			length += 1.4
		else:
			length += 1
	return length

func visualize_grids(grids:Array[Vector2i],color:Color = Color.WHITE) -> void:
	visual_layer.clear()
	visual_layer.modulate = color
	visual_layer.set_cells_terrain_connect(grids,0,0)  #获得地形
