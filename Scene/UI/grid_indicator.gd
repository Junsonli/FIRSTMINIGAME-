extends Node2D

var mouse_grid_position:Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var new_mouse_grid_position = GridManager.get_mouse_grid_position()  #问翻译官：鼠标在第几格？
	if mouse_grid_position  != new_mouse_grid_position:                  #格子变了才更新（同格内晃不动）
		mouse_grid_position = new_mouse_grid_position
		global_position = GridManager.get_world_position(mouse_grid_position)  #把手电筒移到格子中心
