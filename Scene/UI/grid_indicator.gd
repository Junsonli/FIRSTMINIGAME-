extends Node2D

var mouse_grid_position:Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var new_mouse_grid_position = GridManager.get_mouse_grid_position()
	if mouse_grid_position  != new_mouse_grid_position:
		mouse_grid_position = new_mouse_grid_position
		global_position = GridManager.get_world_position(mouse_grid_position)
