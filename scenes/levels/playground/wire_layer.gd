class_name WireLayer extends TileMapLayer

var order_executes_per_frame := 1500
var _logic_queue: Array[Callable]


func _process(_delta: float) -> void:
	if not _logic_queue.is_empty():
		_execute_queue()


func toggle_start_gate() -> void:
	var grid_mouse_position: Vector2i = local_to_map(get_local_mouse_position())

	if not (
			get_cell_source_id(grid_mouse_position) == 1
			and get_cell_atlas_coords(grid_mouse_position) == Vector2i(0, 0)
	):
		return
	var state: bool = not get_cell_alternative_tile(grid_mouse_position)
	set_cell(grid_mouse_position, 1, Vector2i(0, 0), state)
	_try_logic_transfer(grid_mouse_position + Vector2i.RIGHT, state)


func _try_logic_transfer(grid_position: Vector2i, state: int) -> void:
	var tileset_source_id: int = get_cell_source_id(grid_position)
	var next_step: Callable
	if tileset_source_id == 0:
		next_step = Callable(self, &"_wire_update")
	elif tileset_source_id >= 2:
		next_step = Callable(self, &"_gate_update")
	next_step = next_step.bind(grid_position, state)
	if next_step.is_valid():
		_logic_queue.append(next_step)


func _wire_update(grid_position: Vector2i, state: int) -> void:
	if get_cell_alternative_tile(grid_position) == state:
		return
	set_cell(grid_position, 0, get_cell_atlas_coords(grid_position), state)

	var tile_data: TileData = get_cell_tile_data(grid_position)
	var directions: int
	if tile_data:
		directions = tile_data.get_custom_data("connected_directions")
	if directions & EditorMode.Direction.RIGHT:
		_try_logic_transfer(grid_position + Vector2i.RIGHT, state)
	if directions & EditorMode.Direction.DOWN:
		_try_logic_transfer(grid_position + Vector2i.DOWN, state)
	if directions & EditorMode.Direction.LEFT:
		_try_logic_transfer(grid_position + Vector2i.LEFT, state)
	if directions & EditorMode.Direction.UP:
		_try_logic_transfer(grid_position + Vector2i.UP, state)


func _gate_update(grid_position: Vector2i, state: bool) -> void:
	set_cell(grid_position, get_cell_source_id(grid_position), get_cell_atlas_coords(grid_position),
			state)
	# TODO


func _execute_queue() -> void:
	for i in range(order_executes_per_frame):
		if _logic_queue.is_empty():
			return
		var action: Callable = _logic_queue.pop_back()
		if action is Callable:
			action.call()
