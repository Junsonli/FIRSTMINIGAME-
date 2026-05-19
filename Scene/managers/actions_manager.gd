extends Node

class_name ActionsManager

var actions:Array[BaseAction]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#遍历自己的所有子节点（MoveAction、AttackAction等），收集到actions数组里
	#for action:BaseAction 是类型标注，告诉Godot期望这些子节点都是BaseAction类型
	for action:BaseAction in get_children():
		actions.append(action)

func get_action(action_id:String) -> BaseAction:
	var results = actions.filter(func(action:BaseAction): return action.action_id == action_id)
	if results and  not results.is_empty():
		return results[0]
	return null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
