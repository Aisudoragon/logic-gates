class_name WireLayer extends TileMapLayer

var order_executes_per_frame := 1500
var _logic_queue: Array[Callable]


func _process(_delta: float) -> void:
	if not _logic_queue.is_empty():
		_execute_queue()


func toggle_start_gate(mouse_position: Vector2) -> void:
	var grid_mouse_position: Vector2i = local_to_map(to_local(mouse_position))

	if not (
			get_cell_source_id(grid_mouse_position) == 1
			and get_cell_atlas_coords(grid_mouse_position) == Vector2i(1, 0)
	):
		return

	set_cell(mouse_position, 1, Vector2i(1, 0), not get_cell_alternative_tile(mouse_position))
	for neighbor in get_surrounding_cells(mouse_position):
		pass
		# TODO ogarnąć jak rozprzestrzenić logikę


func _execute_queue() -> void:
	for i in range(order_executes_per_frame):
		if _logic_queue.is_empty():
			return
		var action: Callable = _logic_queue.pop_back()
		if action is Callable:
			action.call()
