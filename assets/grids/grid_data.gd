class_name GridData

var walkable:bool = true
var occupied_unit:Unit = null         #存储谁站在这格（null=没人）

func is_occupied_by_unit() -> bool:
	return occupied_unit != null    #这格有没有人占着？
