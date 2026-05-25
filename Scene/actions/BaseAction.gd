extends Node

class_name BaseAction

@export var action_id:String
@export var action_name:String 
@export var grid_color:Color = Color.WHITE

var unit:Unit
var is_active:bool = false
#一个action完全结束后开始下一个action，可以使用信号来实现系统知道action结束，也可以用回调函数。
var on_action_finished:Callable  #Callable可以把函数当作变量进入另一个函数



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	unit = owner

func start_action(target_grid_position:Vector2i,on_action_finished:Callable) -> void:
	is_active = true
	#把外面传进来的回调函数（电话号码）存到自己的成员变量里
	#加self是因为参数名和成员变量名一样，不加self就存不进去
	self.on_action_finished = on_action_finished

func finish_action() -> void:
	is_active = false
	#拨通之前存好的电话，通知外面的人"这个action干完了"
	on_action_finished.call()

func get_action_grids(unit_grid:Vector2i = unit.grid_position) -> Array[Vector2i]:  #仅模板，各技能自己写
	return[]

func is_obstacle(grid_position:Vector2i) -> bool:
	if GridManager.is_grid_occupied(grid_position):
		return false
	return not GridManager.is_grid_walkable(grid_position)

func is_occupied_by_allay(grid_position:Vector2i) -> bool:
	if not GridManager.is_grid_occupied(grid_position):
		return false
	return GridManager.get_grid_occupied(grid_position).is_enemy == unit.is_enemy

func hit_obstacle(starting_grid:Vector2i,ending_grid:Vector2i) -> bool:             #射线检查是否有障碍物
	var starting_position:Vector2 = GridManager.get_world_position(starting_grid)
	var ending_position:Vector2 = GridManager.get_world_position(ending_grid)
	var query_parameters = PhysicsRayQueryParameters2D.create(starting_position,ending_position,2)
	var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
	return not result.is_empty()
