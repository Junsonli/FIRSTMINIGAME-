extends TileMapLayer

class_name Nav_layer

var a_star:AStarGrid2D
var grid_data_dict:Dictionary[Vector2i,GridData] = {}


func _ready() -> void:
	initialize()
	GridManager.nav_layer = self

func initialize() -> void:
	a_star = AStarGrid2D.new()
	a_star.region = get_used_rect()
	a_star.cell_size = tile_set.tile_size
	a_star.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	
	a_star.update()
	
	var used_cells := get_used_cells()
	for cell in used_cells:
		grid_data_dict[cell] = GridData.new()
		if not get_cell_tile_data(cell).get_custom_data("walkable"):
			a_star.set_point_solid(cell)
			grid_data_dict[cell].walkable = false
			
	
