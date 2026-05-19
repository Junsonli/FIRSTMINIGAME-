class_name GridData

var walkable:bool = true
var occupied_unit:Unit = null

func is_occupied_by_unit() -> bool:
	return occupied_unit != null
