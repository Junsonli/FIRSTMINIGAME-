extends MarginContainer

class_name UnitActionUI

@export var action_card_ui_scene:PackedScene

@onready var action_container: HBoxContainer = $MarginContainer/ActionContainer

func _ready() -> void:
	call_deferred("update_unit_actions_ui")

func update_unit_actions_ui() -> void:
	var actions_manager:ActionsManager = get_tree().current_scene.get_node("Unit").get_node("ActionsManager")
	
	for node in action_container.get_children():
		node.queue_free()
	
	for action in actions_manager.actions:
		var action_card_ui:ActionCardUI = action_card_ui_scene.instantiate()
		action_container.add_child(action_card_ui)
		action_card_ui.set_up(action)

# Called when the node enters the scene tree for the first time.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
