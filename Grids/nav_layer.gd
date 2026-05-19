extends TileMapLayer

class_name Nav_layer

var a_star:AStarGrid2D
#档案柜：钥匙=格子号，内容=该格的GridData档案卡
#用 GridData + A* 分开设计：A* 只管寻路，GridData 存详细信息（以后可扩展地形、陷阱等）
var grid_data_dict:Dictionary[Vector2i,GridData] = {}


func _ready() -> void:
	initialize()
	GridManager.nav_layer = self

func initialize() -> void:
	a_star = AStarGrid2D.new()
	a_star.region = get_used_rect()
	a_star.cell_size = tile_set.tile_size
	#A* 初始化三件套：
	#- region：搜索范围（已画瓦片的矩形区域）
	#- cell_size：每格多大（16×16 像素）
	#- diagonal_mode：移动方式（NEVER = 禁止斜向，战棋通常只走上下左右）
	a_star.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	
	a_star.update()
	
	var used_cells := get_used_cells()
	for cell in used_cells:           #遍历所有画了瓦片的格子
		grid_data_dict[cell] = GridData.new()        #给这格发一张档案卡
		if not get_cell_tile_data(cell).get_custom_data("walkable"):
			a_star.set_point_solid(cell)               #告诉A*：这格是墙，寻路时绕开
			grid_data_dict[cell].walkable = false      #档案卡同步标记为不可走
			
		
