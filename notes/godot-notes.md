# Godot 4 战棋教程 —— 项目知识库

> 本文件随项目进度边做边更新，记录"做战棋时真实用到"的知识点。
> **用途：直接粘贴给新 AI，让其快速理解项目背景与已实现内容。**
> 官方完整文档：https://docs.godotengine.org/zh-cn/4.x/

---

## 🪪 项目名片（给 AI 看的）

- **引擎**：Godot 4.6.2，GDScript
- **类型**：俯视角 2D 回合制策略游戏（战棋）
- **学习者背景**：零基础入门，目标为游戏策划（非程序岗），边做边学
- **项目路径**：`D:\Godot_v4.6.2-stable_mono_win64\Projects\回合制策略`
- **核心诉求**：理解实现细节，能搭原型验证设计，能与程序有效沟通

---

## 📌 当前进度

| 模块 | 状态 | 备注 |
|------|------|------|
| 项目搭建 | ✅ 完成 | AutoLoad + TileMapLayer + GridIndicator |
| TileMapLayer 网格 | ✅ 完成 | 鼠标悬停高亮、坐标转换封装 |
| 角色与移动 | ✅ 完成 | Unit 场景、点击寻路、沿路径移动 |
| 寻路系统 | ✅ 完成 | AStarGrid2D、避障、GridData 格子档案 |
| 回合状态机 | ⬜ 未开始 | |
| 技能系统 | ✅ 完成 | 移动/攻击模板 + Action回调 + 技能UI面板 |
| 地形系统 | ⬜ 未开始 | |
| 敌人 AI | ⬜ 未开始 | |

---

## 🧠 Godot 4 核心概念（策划版）

### 1. 节点树（Scene Tree）
- **什么是节点？** 游戏里的每一个"东西"都是一个节点：角色、地图、相机、血条……
- **什么是场景（Scene）？** 一个保存好的节点树片段，可以重复使用。比如"玩家单位"做成一个场景，战场上放 5 个就是 5 个实例。
- **父子关系：** 子节点会跟随父节点移动、缩放、隐藏。比如血条作为角色的子节点，角色走到哪里血条跟到哪里。
- **关键理解：** Godot 是**组合优于继承**。一个角色节点身上"挂"上移动脚本、攻击脚本、动画节点，拼出来一个完整角色，而不是写一个巨型类。

### 2. 信号（Signal）
- **作用：** 节点之间的"广播通知"。解耦，避免 A 直接调用 B 的代码。
- **生活类比：** 你（A）不需要知道快递员（B）的电话，你只需要在 App 上点"发货提醒"（连接信号），货到了就收到通知。
- **战棋常用场景：**
  - 角色死亡 → 发出 `died` 信号 → 回合控制器收到后检查是否胜负已分
  - 回合切换 → 发出 `turn_changed` 信号 → UI 更新当前回合显示

### 3. 脚本附加（Attach Script）
- 给节点"附加"一个 GDScript 文件，这个节点就获得了脚本里定义的行为。
- 一个节点只能附加**一个**脚本，但脚本里可以引用其他节点和脚本。

---

## 📝 GDScript 语法精要（战棋够用版）

### 变量与类型（可选但推荐写）
```gdscript
var health: int = 100          # 整数
var speed: float = 3.5         # 小数
var unit_name: String = "骑士"  # 字符串
var is_enemy: bool = false     # 布尔
var target: Node2D             # 对象引用
```
> 加 `: 类型` 是可选的，但写了能提前发现错误，策划也更容易读懂。

### 数组与字典（配置数据常用）
```gdscript
# 数组：按顺序存一堆东西
var skills: Array[String] = ["火球", "冰冻", "治疗"]

# 字典：键值对，查东西快
var unit_stats = {
    "attack": 15,
    "defense": 8,
    "move_range": 5
}
print(unit_stats["attack"])  # 输出 15
```

### 函数
```gdscript
# 返回值类型写在后面
func take_damage(amount: int) -> void:
    health -= amount
    if health <= 0:
        die()

# 有返回值的函数
func get_move_range() -> int:
    return move_range
```

### 流程控制
```gdscript
# 判断
if is_enemy:
    modulate = Color.RED
elif health < 30:
    modulate = Color.YELLOW
else:
    modulate = Color.WHITE

# 循环
for neighbor in neighbors:
    if can_move_to(neighbor):
        highlight_tile(neighbor)
```

### 常用关键字速查
| 关键字 | 含义 | 例子 |
|--------|------|------|
| `extends` | 继承哪个类 | `extends CharacterBody2D` |
| `@export` | 在编辑器面板里可调 | `@export var speed: int = 5` |
| `@onready` | 等节点准备好再赋值 | `@onready var sprite = $Sprite2D` |
| `$NodeName` | 获取子节点 | `$Sprite2D.visible = false` |
| `signal` | 定义信号 | `signal died` |
| `emit_signal` | 发射信号 | `emit_signal("died")` 或 `died.emit()` |
| `await` | 等待某个信号/完成 | `await anim_player.animation_finished` |

---

## 🎮 战棋系统知识库（边做边填）

### □ TileMapLayer 网格系统

**官方类：** `TileMapLayer`（Godot 4.3+）

**核心概念：**
- `TileMapLayer` 是放置瓦片的画布。逻辑基于**网格坐标**（`Vector2i`，整数格子号），显示基于**世界坐标**（`Vector2`，像素）。
- 坐标转换必须经过**局部坐标**（`to_local` / `to_global`），因为 NavLayer 可能偏移/缩放/旋转。不能省略。

**坐标转换（核心公式）：**
```gdscript
# 世界坐标 → 网格坐标
var grid = nav_layer.local_to_map(nav_layer.to_local(world_pos))

# 网格坐标 → 世界坐标（格子中心）
var world = nav_layer.to_global(nav_layer.map_to_local(grid_pos))
```

**第一集实现结构：**
```
LevelScene
├── NavLayer (TileMapLayer)  ← nav_layer.gd
│   └── _ready(): GridManager.nav_layer = self
│
├── GridIndicator (Node2D)   ← grid_indicator.gd
│   └── Sprite2D (HighlightGrid.png)
│   └── _process(): 每帧取鼠标网格坐标 → 变化时更新 global_position
│
AutoLoad: GridManager (Node) ← grid_manager.gd
    ├── var nav_layer: TileMapLayer
    ├── get_grid_position(world_pos) → Vector2i
    ├── get_world_position(grid_pos) → Vector2
    └── get_mouse_grid_position() → Vector2i
```

**关键 API：**
| 方法 | 作用 |
|------|------|
| `get_global_mouse_position()` | 获取鼠标世界像素坐标 |
| `to_local(global_pos)` | 世界坐标 → 节点局部坐标 |
| `to_global(local_pos)` | 节点局部坐标 → 世界坐标 |
| `local_to_map(local_pos)` | 局部像素 → 网格坐标（÷ cell_size） |
| `map_to_local(map_coords)` | 网格坐标 → 局部像素中心（× cell_size + 半格） |
| `global_position` | Node2D 在世界中的位置 |

**性能优化：**
- GridIndicator 只在 `mouse_grid_position` 变化时才更新 `global_position`，避免每帧重设。

**资源：**
- `assets/grids/NaviData.png` — TileSet 图集（32×16，切为 2 个 16×16 瓦片）
- `assets/grids/HighlightGrid.png` — 鼠标悬停高亮精灵
- `resources/nav_tile_set.tres` — TileSet 配置

---

### □ 角色与移动

**新增文件：**
- `Scene/units/unit.tscn` — Node2D + Sprite2D(icon.svg)
- `Scene/units/unit.gd` — 角色脚本

**核心逻辑：**
```gdscript
# 点击 → 寻路 → 存路径
func _unhandled_input(event):
    if event.is_action_pressed("left_mouse_click"):
        var mouse_grid = GridManager.get_mouse_grid_position()
        path = GridManager.get_nav_world_path(grid_position, mouse_grid)

# 每帧沿路径走
func _process(delta):
    if path and not path.is_empty():
        move(path[0], delta)
        if global_position == path[0]:
            path.remove_at(0)  # 踩到就删，走下一个

# 平滑移动
func move(target, delta):
    global_position = global_position.move_toward(target, move_speed * delta)
```

**路径跟随机制：**
- `path` 是 `Array[Vector2]`（像素坐标路径点）
- 角色始终盯着 `path[0]` 移动，到达后 `remove_at(0)`
- 类比：踩着一排脚印走，踩一个擦一个

**关键 API：**
| API | 作用 |
|-----|------|
| `_unhandled_input(event)` | UI 处理完后才接收的输入（避免点按钮误触发移动） |
| `move_toward(target, step)` | 朝目标平滑移动，到了直接跳到位 |
| `remove_at(index)` | 删除数组指定索引元素 |
| `class_name Unit` | 注册全局类名，其他脚本可声明 `var u: Unit` |

---

### □ 寻路系统

**A* 寻路（第二节）：**

```gdscript
# nav_layer.gd 中初始化
a_star = AStarGrid2D.new()
a_star.region = get_used_rect()         # 搜索范围 = 已画瓦片的矩形
a_star.cell_size = tile_set.tile_size   # 每格 16×16
a_star.diagonal_mode = DIAGONAL_MODE_NEVER  # 禁止斜向
a_star.update()
```

```gdscript
# GridManager 提供路径查询
func get_nav_grid_path(start, end) -> Array[Vector2i]:
    return nav_layer.a_star.get_id_path(start, end)  # 返回格子号路径

func get_nav_world_path(start, end) -> Array[Vector2]:
    # 先拿格子路径，再逐个转成像素坐标
```

**避障（第三节）：**

**1. TileSet 自定义数据层标记地形：**
```
nav_tile_set.tres:
- custom_data_layer_0/name = "walkable"
- 0:0/0/custom_data_0 = true   ← 瓦片 0:0 是地板
- 1:0/0 无标记 → 默认 false   ← 瓦片 1:0 是墙
```
编辑器用不同瓦片刷地图，就自带了 walkable 属性。

**2. GridData 格子档案卡：**
```gdscript
# assets/grids/grid_data.gd
class_name GridData
var walkable: bool = true
var occupied_unit: Unit = null
func is_occupied_by_unit() -> bool:
    return occupied_unit != null
```

**3. NavLayer 初始化时建档并标记障碍：**
```gdscript
var grid_data_dict: Dictionary[Vector2i, GridData] = {}

func initialize():
    # ... A* 初始化 ...
    var used_cells := get_used_cells()
    for cell in used_cells:
        grid_data_dict[cell] = GridData.new()
        if not get_cell_tile_data(cell).get_custom_data("walkable"):
            a_star.set_point_solid(cell)           # A* 标记障碍
            grid_data_dict[cell].walkable = false  # 档案卡同步
```

**4. GridManager 格子状态查询接口：**
```gdscript
is_valid_grid(grid)        # 格子是否存在（防点在地图外）
is_grid_walkable(grid)     # 是否可行走
set_grid_walkable(grid, v) # 动态修改（如开门），同步更新 A* solid
is_grid_occupied(grid)     # 是否被单位占据
get_grid_occupied(grid)    # 获取占据该格的单位
set_grid_occupied(grid, u) # 设置/清空占据单位
```

**设计意图：**
- `GridData` 是**数据源**（地形、占据、以后可扩展移动力/陷阱等）
- `AStarGrid2D` 是**消费者**（只管寻路）
- 两者解耦：改 GridData 后同步 A* 即可，其他逻辑不依赖 A* 内部

**关键 API：**
| API | 作用 |
|-----|------|
| `get_used_cells()` | 获取所有已绘制瓦片的格子坐标 |
| `get_cell_tile_data(cell)` | 获取指定格的 TileData |
| `get_custom_data("walkable")` | 读 TileSet 自定义数据层 |
| `a_star.set_point_solid(cell, bool)` | 设置/取消 A* 障碍 |
| `a_star.get_id_path(start, end)` | A* 算最短路径，返回格子号数组 |
| `dictionary.has(key)` | 字典是否包含某键 |

---

### □ 状态机（回合切换）

**待记录：**
- 为什么用状态机：避免 `if-else` 地狱，回合逻辑清晰
- `State` 基类设计
- 常见状态：玩家回合 → 敌人回合 → 胜利/失败
- 状态转换的触发条件

**教程实践记录：**
> （此处待填写）

---

### □ 技能系统

**第四集：初步搭建（骨架阶段）**

**新增文件：**
- `Scene/actions/BaseAction.gd` — 技能基类（`class_name BaseAction`）
- `Scene/managers/actions_manager.gd` — 技能管理器（`class_name ActionsManager`）

**核心设计：把移动/攻击抽象为 Action，统一接口管理**

**BaseAction 基类：**
```gdscript
class_name BaseAction

@export var action_id:String        # 技能身份证，如 "move"
@export var action_name:String      # 显示名，如 "移动"
var unit:Unit                       # 所属角色（_ready 时从 owner 获取）
var is_active:bool = false          # 是否正在执行
var on_action_finished:Callable     # 回调函数：技能结束时通知外部

func start_action(target_grid_position:Vector2i, on_action_finished:Callable):
    is_active = true
    self.on_action_finished = on_action_finished   # 存下回调，结束时报信

func finish_action():
    is_active = false
    on_action_finished.call()                      # 拨通电话，通知"干完了"
```

**ActionsManager 管理器：**
```gdscript
class_name ActionsManager

var actions:Array[BaseAction]

func _ready():
    # 遍历自己的子节点（MoveAction/AttackAction等），收集到数组
    for action:BaseAction in get_children():
        actions.append(action)

func get_action(action_id:String) -> BaseAction:
    # filter + lambda 匿名函数：按 action_id 筛选
    var results = actions.filter(func(a): return a.action_id == action_id)
    if not results.is_empty():
        return results[0]
    return null
```

**关键概念：**

| 概念 | 说明 |
|------|------|
| `Callable` | 把函数当变量存起来，需要时 `.call()` 执行。类比：把电话号码存进通讯录，以后拨打 |
| `self.xxx = xxx` | 参数名和成员变量同名时，加 `self.` 表示"存到成员变量" |
| `filter(func):` | 数组筛选，传入匿名函数作为筛选条件 |
| `get_children()` | 获取当前节点的所有直接子节点 |

**设计意图：**
- **解耦**：Unit 只管"收到输入"，ActionsManager 管"交给谁"，BaseAction 子类管"具体怎么做"
- **排队执行**：一个 action 结束后通过回调通知，才能开始下一个
- **无限扩展**：新增技能 = 新增继承 BaseAction 的脚本 + 挂到 ActionsManager 下 + 设置 action_id

**第五集：MoveAction + 其他技能模板**

**新增/修改文件：**
- `Scene/actions/move_action.gd` — 移动技能，继承 BaseAction
- `Scene/actions/bow_action.gd` — 弓箭技能模板（占位）
- `Scene/actions/sword_action.gd` — 剑击技能模板（占位）
- `Scene/actions/fireball_action.gd` — 火球技能模板（占位）
- `Scene/units/unit.gd` — 重构：移动逻辑移出，交给 MoveAction 处理
- `Scene/units/unit.tscn` — ActionsManager 下挂载了 4 个 Action 子节点

**MoveAction（第一个具体厨师）：**
```gdscript
extends BaseAction
class_name MoveAction

var path:Array[Vector2]
var move_speed:float = 100

func start_action(target_grid_position, on_action_finished):
    super.start_action(target_grid_position, on_action_finished)  # 先执行父类标准流程（is_active=true+存回调）
    path = GridManager.get_nav_world_path(unit.grid_position, target_grid_position)  # 再算自己的路径

func _process(delta):
    if not is_active:          # 保险栓：没激活时不执行
        return
    if path and not path.is_empty():
        unit.global_position = unit.global_position.move_toward(path[0], move_speed * delta)
        if unit.global_position == path[0]:
            path.remove_at(0)
    else:
        finish_action()        # 路径走完了，通知外面"干完了"
```

**关键变化：**
| 以前（Unit 自己管） | 现在（MoveAction 管） |
|---------------------|----------------------|
| `var path` / `move_speed` | 搬进了 MoveAction |
| `_unhandled_input` 里算路径 | `start_action` 里算路径 |
| `_process` 里走路 | `_process` 里走路 |
| `global_position` | `unit.global_position`（通过 unit 引用操作角色） |

**Unit 重构后：**
```gdscript
@onready var actions_manager: ActionsManager = $ActionsManager
var is_performing_action:bool = false          # 状态锁：防止狂点鼠标导致技能叠发

func on_action_finished():                     # 技能结束时的回调
    is_performing_action = false               # 解锁，可以接受下一个指令

func _unhandled_input(event):
    if is_performing_action:                   # 正在执行？忽略新输入
        return
    if event.is_action_pressed("left_mouse_click"):
        var mouse_grid = GridManager.get_mouse_grid_position()
        is_performing_action = true            # 上锁
        actions_manager.get_action("move_action").start_action(mouse_grid, on_action_finished)
```

**Callable 名片机制（跨对象回调的本质）：**
- `on_action_finished` 不加括号 → 创建 `Callable` 对象，记录**对象地址（Unit）+ 函数名**
- MoveAction 调用 `.call()` 时，Godot 根据名片上的地址找到 Unit，在其身上执行函数
- 不是"跨脚本传播"，是"函数引用自带回家地址"

**其他技能模板：**
BowAction / SwordAction / FireballAction 目前只 `print` 然后 `finish_action()`，证明扩展性：新增技能 = 新建脚本 + 挂到 ActionsManager 下 + 设置 action_id，Unit 和 ActionsManager **完全不用改**。

**设计验证：**
- ✅ 解耦：Unit 只管"喊开工"，MoveAction 管"怎么走路"
- ✅ 状态锁：`is_performing_action` 防止连点导致多个 action 并行
- ✅ 扩展性：新增技能不改动现有代码
**第六集：技能UI面板**

**新增文件：**
- `Scene/UI/game_ui.tscn` — CanvasLayer 总UI层
- `Scene/UI/unity_actions_ui.gd` — UnitActionUI 技能面板
- `Scene/UI/actio_card_ui.gd` — ActionCardUI 单个技能按钮

**核心流程：**
```gdscript
# UnitActionUI._ready() 中延迟生成按钮
call_deferred("update_unit_actions_ui")

func update_unit_actions_ui():
    # 1. 清空旧按钮
    for node in action_container.get_children():
        node.queue_free()
    
    # 2. 遍历 ActionsManager 的所有技能
    for action in actions_manager.actions:
        var btn = action_card_ui_scene.instantiate()  # 从 PackedScene 图纸造实例
        action_container.add_child(btn)               # 塞进 HBoxContainer 横向排列
        btn.set_up(action)                            # 设置按钮文字 = action.action_name
```

**关键概念：**

| 概念 | 说明 |
|------|------|
| `PackedScene` | 预制件/图纸，存着节点模板 |
| `instantiate()` | 用图纸造出真的实例 |
| `add_child()` | 把节点挂到父节点下 |
| `queue_free()` | 排队销毁（安全版删除） |
| `call_deferred()` | 延迟到下一帧执行，避免初始化顺序问题 |
| `CanvasLayer` | UI 专用层，渲染在最上层，不受相机影响 |
| `HBoxContainer` | 横向自动排列子节点 |
| `@export PackedScene` | 在编辑器 Inspector 里拖入预制件 |

**场景结构：**
```
LevelScene
├── GameUI (CanvasLayer)
│   └── UnitActionsUI (MarginContainer)
│       └── MarginContainer
│           └── ActionContainer (HBoxContainer)
│               ├── [Button: Move]
│               ├── [Button: Bow]
│               ├── [Button: Sword]
│               └── [Button: Fireball]
```

**第七集：技能选择（大重构）**

**新增/修改文件：**
- `Scene/autoLoads/player_action_manager.gd` — **新增 AutoLoad 单例**：全局管理技能选择、输入处理、状态锁
- `Scene/units/unit.gd` — **大幅瘦身**：删除输入逻辑、状态锁、移动相关，只剩 `actions_manager` 和 `grid_position`
- `Scene/UI/actio_card_ui.gd` — **新增点击**：`pressed.connect(on_action_seleted)`，点击按钮通知 PlayerActionManager 切换技能
- `Scene/level_scene.gd` — **新增**：启动时默认选中移动技能
- `project.godot` — 新增 AutoLoad `PlayerActionManager`

**PlayerActionManager（全局前台）：**
```gdscript
extends Node

var is_performing_action:bool = false   # 全局状态锁（只有一份）
var selected_action:BaseAction          # 当前选中的技能

func _unhandled_input(event):
    if is_performing_action: return
    if event.is_action_pressed("left_mouse_click"):
        try_perform_selected_action()

func set_selected_action(action:BaseAction):
    if is_performing_action: return
    if selected_action == action: return
    selected_action = action           # 切换当前技能

func try_perform_selected_action():
    if is_performing_action: return
    if selected_action == null: return
    var target = GridManager.get_mouse_grid_position()
    is_performing_action = true        # 上锁
    selected_action.start_action(target, on_action_finished)

func on_action_finished():
    is_performing_action = false       # 解锁
```

**三个函数的"人设"：**
| 函数 | 作用 | 调用时机 |
|------|------|---------|
| `set_selected_action` | 切换当前技能 | 点 UI 按钮时 |
| `try_perform_selected_action` | 执行当前技能 | 点鼠标左键时 |
| `on_action_finished` | 解锁，允许下一个指令 | 技能回调 |

**Unit 瘦身后的职责：**
```gdscript
extends Node2D
class_name Unit

@onready var actions_manager: ActionsManager = $ActionsManager

var grid_position:Vector2i:
    get:return GridManager.get_grid_position(global_position)
```
只剩两件事：知道自己有哪些技能、知道自己在哪格。

**ActionCardUI 点击选择：**
```gdscript
func _ready():
    pressed.connect(on_action_seleted)   # 按钮按下时触发

func on_action_seleted():
    PlayerActionManager.set_selected_action(action)  # 通知全局前台换技能
```

**为什么用 AutoLoad？**
- PlayerActionManager 是全局单例，任何脚本都能直接访问
- 不需要 `get_node` 层层找，直接写名字
- 多个角色时，输入由全局统一管理，不会冲突

**设计验证：**
- ✅ 解耦：Unit 不管输入，只管"我是谁我在哪"
- ✅ 全局状态锁：`is_performing_action` 只有一份，防止连点
- ✅ 动态技能切换：点了按钮换技能，点鼠标执行当前技能
- ✅ 初始化默认：`LevelScene._ready` 默认选中移动
- ✅ 信号连接：`pressed.connect(...)` 按钮点击 → 切换技能

---

### □ 地形系统

**待记录：**
- `Terrain Set` 的用途：一套地形规则（如草地、山地、水域）
- 地形如何影响移动力/防御加成
- 高效绘制：一次性刷一大片地形

**教程实践记录：**
> （此处待填写）

---

### □ 敌人 AI

**待记录：**
- 简单 AI 思路：找最近敌人 → 判断能否攻击 → 移动/攻击
- Godot 中 AI 决策的执行时机（敌人回合状态内）

**教程实践记录：**
> （此处待填写）

---

## 🔗 常用官方文档直达

| 主题 | 链接 |
|------|------|
| GDScript 基础 | https://docs.godotengine.org/zh-cn/4.x/tutorials/scripting/gdscript/gdscript_basics.html |
| TileMapLayer | https://docs.godotengine.org/zh-cn/4.x/classes/class_tilemaplayer.html |
| AStarGrid2D | https://docs.godotengine.org/zh-cn/4.x/classes/class_astargrid2d.html |
| 信号使用 | https://docs.godotengine.org/zh-cn/4.x/getting_started/step_by_step/signals.html |
| 状态机设计 | https://docs.godotengine.org/zh-cn/4.x/tutorials/best_practices/godot_notifications.html |
