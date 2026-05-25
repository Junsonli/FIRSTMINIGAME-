extends Button

class_name ActionCardUI

var action:BaseAction

func set_up(action:BaseAction) -> void:
	self.action = action
	text = action.action_name

func on_action_seleted() -> void:
	PlayerActionManager.set_selected_action(action)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(on_action_seleted)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
