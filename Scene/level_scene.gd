extends Node

@onready var visual_layer: TileMapLayer = $VisualLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GridManager.visual_layer = visual_layer
	
	var action = get_tree().current_scene.get_node("Unit").actions_manager.get_action("move_action")
	PlayerActionManager.set_selected_action(action)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
