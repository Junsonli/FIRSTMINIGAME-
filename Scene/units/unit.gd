extends Node2D

class_name Unit

var target_global_position:Vector2

var move_speed:float = 100

var path:Array[Vector2]

var grid_position:Vector2i:
	get:return GridManager.get_grid_position(global_position)

func _unhandled_input(event: InputEvent) -> void: #用这个是防止和UI的input重置，unhandleinput会在处理完UI的输入后再处理
	if event.is_action_pressed("left_mouse_click"):
		var mouse_grid_position = GridManager.get_mouse_grid_position()
		target_global_position = GridManager.get_world_position(mouse_grid_position)
		path = GridManager.get_nav_world_path(grid_position,mouse_grid_position)

func move(target_global_position:Vector2,delta: float) -> void:
	global_position = global_position.move_toward(target_global_position,move_speed * delta)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if path and not path.is_empty():
		move(path[0],delta)
		if global_position == path[0]:
			path.remove_at(0)
