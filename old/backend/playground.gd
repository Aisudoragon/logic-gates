extends Node2D

var startDrawingPos: Vector2i
@onready var wire_layer: TileMapLayer = $WireLayer
@onready var gate_layer: TileMapLayer = $GateLayer
@onready var highlight_layer: TileMapLayer = $HighlightLayer
@onready var camera: Camera2D = $Camera2D


func _unhandled_input(event: InputEvent) -> void:
	var mouse_position: Vector2i = wire_layer.local_to_map(wire_layer.get_local_mouse_position())

	if event.is_action_pressed("place"):
		startDrawingPos = mouse_position

	highlight_layer.clear()

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		highlight_wire(startDrawingPos, mouse_position)
	else:
		highlight_layer.set_cell(mouse_position, 0, Vector2i(0,0), 0)
	if event.is_action_released("place"):
		place_wire()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		wire_layer.set_cell(mouse_position, 0)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var size: Vector2 = get_viewport_rect().size * camera.zoom / 2
	var cam: Vector2 = camera.position
	for i in range(int((cam.x - size.x) / 64) - 1, int ((size.x + cam.x) / 64) + 1):
		draw_line(Vector2(i * 64, cam.y + size.y + 100), Vector2(i * 64, cam.y - size.y - 100), "00000030")
	for i in range(int((cam.y - size.y) / 64) - 1, int((size.y + cam.y) / 64) + 1):
		draw_line(Vector2(cam.x + size.x + 100, i * 64), Vector2(cam.x - size.x - 100, i * 64), "00000030")


func place_wire() -> void:
	var cells_to_copy: Array[Vector2i] = highlight_layer.get_used_cells()
	for pos in cells_to_copy:
		var cell: TileData = highlight_layer.get_cell_tile_data(pos)
		wire_layer._tile_data_runtime_update(pos, cell)


func highlight_wire(start_pos: Vector2i, end_pos: Vector2i) -> void:
	var tiles_len : Vector2i = end_pos - start_pos
	var min_pos : Vector2i = start_pos.min(end_pos)
	var max_pos : Vector2i = start_pos.max(end_pos)

	for i in range(0, absi(tiles_len.x) + 1):
		highlight_layer.set_cell(Vector2i(min_pos.x + i, min_pos.y), 0, Vector2i(4, 0), 2)
	for i in range(0, absi(tiles_len.y) + 1):
		highlight_layer.set_cell(Vector2(max_pos.x, min_pos.y + i), 0, Vector2i(4, 0), 2)

	for i in range(0, absi(tiles_len.x) + 1):
		var tile_pos: Vector2i = Vector2i(min_pos.x + i, min_pos.y)
		var tile_info: Array = connect_wire(tile_pos)
		highlight_layer.set_cell(tile_pos, 0, tile_info[0], tile_info[1])
	for i in range(0, absi(tiles_len.y) + 1):
		var tile_pos: Vector2i = Vector2i(max_pos.x, min_pos.y + i)
		var tile_info: Array = connect_wire(tile_pos)
		highlight_layer.set_cell(tile_pos, 0, tile_info[0], tile_info[1])


func connect_wire(position: Vector2i) -> Array:
	var neighbors: Array[Vector2i] = highlight_layer.get_surrounding_cells(position)
	if not highlight_layer.get_cell_source_id(neighbors[0]) == -1:  # Checks right side
		if not highlight_layer.get_cell_source_id(neighbors[1]) == -1:  # Checks bottom side
			if not highlight_layer.get_cell_source_id(neighbors[2]) == -1:  # Checks left side
				if not highlight_layer.get_cell_source_id(neighbors[3]) == -1:  # Checks top side
					return [Vector2(4, 0), 2]
				return [Vector2i(3, 0), 2]
			elif not highlight_layer.get_cell_source_id(neighbors[3]) == -1:  # Checks top side
				return [Vector2i(3, 0), 8]
			return [Vector2i(2, 0), 2]
		elif not highlight_layer.get_cell_source_id(neighbors[2]) == -1:  # Checks left side
			if not highlight_layer.get_cell_source_id(neighbors[3]) == -1:  # Checks top side
				return [Vector2i(3, 0), 6]
			return [Vector2i(1, 0), 4]
		elif not highlight_layer.get_cell_source_id(neighbors[3]) == -1:  # Checks top side
			return [Vector2i(2, 0), 8]
		return [Vector2i(0, 0), 8]
	elif not highlight_layer.get_cell_source_id(neighbors[1]) == -1:  # Checks bottom side
		if not highlight_layer.get_cell_source_id(neighbors[2]) == -1:  # Checks left side
			if not highlight_layer.get_cell_source_id(neighbors[3]) == -1:  # Checks top side
				return [Vector2i(3, 0), 4]
			return [Vector2i(2, 0), 4]
		elif not highlight_layer.get_cell_source_id(neighbors[3]) == -1:  # Checks top side
			return [Vector2i(1, 0), 2]
		return [Vector2(0, 0), 2]
	elif not highlight_layer.get_cell_source_id(neighbors[2]) == -1:  # Checks left side
		if not highlight_layer.get_cell_source_id(neighbors[3]) == -1:  # Checks top side
			return [Vector2i(2, 0), 6]
		return [Vector2i(0, 0), 4]
	elif not highlight_layer.get_cell_source_id(neighbors[3]) == -1:  # Checks top side
		return [Vector2(0, 0), 6]
	return [Vector2(4, 0), 2]
