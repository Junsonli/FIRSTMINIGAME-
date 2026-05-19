extends Node2D

class_name Unit

var target_global_position:Vector2

var move_speed:float = 100

var path:Array[Vector2]

var grid_position:Vector2i:
	get:return GridManager.get_grid_position(global_position)

func _unhandled_input(event: InputEvent) -> void: 			#用_unhandled_input是防止和UI的输入冲突，UI处理完剩余的输入才到这里
	if event.is_action_pressed("left_mouse_click"):
		var mouse_grid_position = GridManager.get_mouse_grid_position()            #获取鼠标当前所在的网格坐标
		target_global_position = GridManager.get_world_position(mouse_grid_position)            #目标网格坐标→目标像素坐标（备用）
		path = GridManager.get_nav_world_path(grid_position,mouse_grid_position)            #A*寻路：返回像素坐标路径数组

func move(target_global_position:Vector2,delta: float) -> void:
	#朝目标平滑移动，move_speed * delta = 这一帧走多少像素（保证和帧率无关）
	global_position = global_position.move_toward(target_global_position,move_speed * delta)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if path and not path.is_empty():        #path不为空才移动
		move(path[0],delta)                 #朝第一个路径点移动
		if global_position == path[0]:      #到了？
			path.remove_at(0)               #擦掉这个点，走下一个
