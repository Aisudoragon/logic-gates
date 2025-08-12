class_name HighlightLayer extends TileMapLayer

var wire_buffer_position: Array[Vector2i]
var _gate_rotation: int = 0


func add_checkpoint(mouse_position: Vector2) -> void:
	var grid_mouse_position: Vector2i = _mouse_to_grid(mouse_position)
	if wire_buffer_position.is_empty():
		wire_buffer_position.append(grid_mouse_position)
	wire_buffer_position.append(grid_mouse_position)
	wire_buffer_position.append(grid_mouse_position)


func rotate_gate() -> void:
	_gate_rotation += 1 if _gate_rotation < 3 else -3


func wire_highlight(mouse_position: Vector2) -> void:
	clear()

	wire_buffer_position[-1] = _mouse_to_grid(mouse_position)
	if wire_buffer_position[-2].x == wire_buffer_position[-3].x:
		wire_buffer_position[-2].y = wire_buffer_position[-1].y
	else:
		wire_buffer_position[-2].x = wire_buffer_position[-1].x

	for index in range(0, wire_buffer_position.size() - 2, 2):
		var start: Vector2i = wire_buffer_position[index]
		var middle: Vector2i = wire_buffer_position[index + 1]
		var end: Vector2i = wire_buffer_position[index + 2]
		var direction: Vector2i = (middle - start).sign()
		_wire_highlight_line(start, middle, direction)
		direction = (end - middle).sign()
		_wire_highlight_line(middle, end, direction)


func gate_highlight(_mouse_position: Vector2) -> void:
	clear()
	#TODO


func _wire_highlight_line(from: Vector2i, to: Vector2i, direction: Vector2i) -> void:
	if from.x == to.x and direction.y:
		for buffer_y in range(from.y, to.y + direction.y, direction.y):
			if buffer_y != to.y:
				_update_tile_wire_direction(Vector2i(from.x, buffer_y), Vector2i(0, direction.y))
			if buffer_y != from.y:
				_update_tile_wire_direction(Vector2i(from.x, buffer_y), Vector2i(0, -direction.y))
	elif direction.x:
		for buffer_x in range(from.x, to.x + direction.x, direction.x):
			if buffer_x != to.x:
				_update_tile_wire_direction(Vector2i(buffer_x, from.y), Vector2i(direction.x, 0))
			if buffer_x != from.x:
				_update_tile_wire_direction(Vector2i(buffer_x, from.y), Vector2i(-direction.x, 0))


func _update_tile_wire_direction(grid_position: Vector2i, direction_vector: Vector2i, add := true) -> void:
	var directions: int
	var tile_data: TileData = get_cell_tile_data(grid_position)
	if tile_data:
		directions = tile_data.get_custom_data("connected_directions")
	var direction_from_vector := (
			EditorMode.Direction.RIGHT if direction_vector == Vector2i.RIGHT
			else EditorMode.Direction.DOWN if direction_vector == Vector2i.DOWN
			else EditorMode.Direction.LEFT if direction_vector == Vector2i.LEFT
			else EditorMode.Direction.UP if direction_vector == Vector2i.UP
			else 0)
	if add:
		directions |= direction_from_vector
	else:
		directions &= ~directions

		if not directions:
			erase_cell(grid_position)
			return
	set_cell(grid_position, 0, Vector2i(directions, 0))


func _mouse_to_grid(mouse_position: Vector2) -> Vector2i:
	return local_to_map(to_local(mouse_position))


func _change_direction_line() -> void:
	var start: Vector2i = wire_buffer_position[-3]
	var end: Vector2i = wire_buffer_position[-1]
	if start.x == wire_buffer_position[-2].x:
		wire_buffer_position[-2] = Vector2i(end.x, start.y)
	else:
		wire_buffer_position[-2] = Vector2i(start.x, end.y)
