extends Node2D

var startDrawingPos: Vector2i
@onready var wire_layer: TileMapLayer = $WireLayer
@onready var gate_layer: TileMapLayer = $GateLayer
@onready var highlight_layer: TileMapLayer = $HighlightLayer
@onready var logic_layer: TileMapLayer = $LogicLayer
@onready var camera: Camera2D = $Camera2D


func _unhandled_input(event: InputEvent) -> void:
	var mouse_position: Vector2i = wire_layer.local_to_map(wire_layer.get_local_mouse_position())

	if event is InputEventMouseButton:
		var event_mb: InputEventMouseButton = event
		if event_mb.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				startDrawingPos = mouse_position
			if event.is_released():
				layout_wire(startDrawingPos, mouse_position, wire_layer)
		layout_wire(startDrawingPos, mouse_position, highlight_layer)
		if event_mb.button_index == MOUSE_BUTTON_RIGHT:
			wire_layer.set_cell(mouse_position, 0)
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			layout_wire(startDrawingPos, mouse_position, highlight_layer)
			print("test")

	highlight_layer.clear()
	highlight_layer.set_cell(mouse_position, 0, Vector2i(0,0), 0)


func layout_wire(start_pos: Vector2i, end_pos: Vector2i, layer: TileMapLayer) -> void:
	var tiles_len : Vector2i = end_pos - start_pos
	var min_pos : Vector2i = start_pos.min(end_pos)
	var max_pos : Vector2i = start_pos.max(end_pos)

	for i in range(0, absi(tiles_len.x) + 1):
		layer.set_cell(Vector2i(min_pos.x + i, min_pos.y), 0, Vector2i(4, 0), 2)
	for i in range(0, absi(tiles_len.y) + 1):
		layer.set_cell(Vector2(max_pos.x, min_pos.y + i), 0, Vector2i(4, 0), 2)

	for i in range(0, absi(tiles_len.x) + 1):
		var tile_pos: Vector2i = Vector2i(min_pos.x + i, min_pos.y)
		var tile_info: Vector3i = connect_wire(tile_pos, layer)
		layer.set_cell(tile_pos, 0, Vector2i(tile_info.x, tile_info.y), tile_info.z)
	for i in range(0, absi(tiles_len.y) + 1):
		var tile_pos: Vector2i = Vector2i(max_pos.x, min_pos.y + i)
		var tile_info: Vector3i = connect_wire(tile_pos, layer)
		layer.set_cell(tile_pos, 0, Vector2i(tile_info.x, tile_info.y), tile_info.z)


func connect_wire(cell_position: Vector2i, layer: TileMapLayer) -> Vector3i:
	var neighbors: Array[Vector2i] = layer.get_surrounding_cells(cell_position)
	var right_n: bool = false if layer.get_cell_source_id(neighbors[0]) == -1 else true
	var bottom_n: bool = false if layer.get_cell_source_id(neighbors[1]) == -1 else true
	var left_n: bool = false if layer.get_cell_source_id(neighbors[2]) == -1 else true
	var top_n: bool = false if layer.get_cell_source_id(neighbors[3]) == -1 else true

	if right_n:
		if bottom_n:
			if left_n:
				if top_n:
					# right, bottom, left, top
					return Vector3i(4, 0, 0)
				# right, bottom, left
				return Vector3i(3, 0, 0)
			elif top_n:
				# right, bottom, top
				return Vector3i(3, 0, 3)
			# right, bottom
			return Vector3i(2, 0, 0)
		elif left_n:
			if top_n:
				# right, left, top
				return Vector3i(3, 0, 2)
			# right, left
			return Vector3i(1, 0, 1)
		elif top_n:
			# right, top
			return Vector3i(2, 0, 3)
		# right
		return Vector3i(0, 0, 3)
	elif bottom_n:
		if left_n:
			if top_n:
				# bottom, left, top
				return Vector3i(3, 0, 1)
			# bottom, left
			return Vector3i(2, 0, 1)
		elif top_n:
			# bottom, top
			return Vector3i(1, 0, 0)
		# bottom
		return Vector3i(0, 0, 0)
	elif left_n:
		if top_n:
			# left, top
			return Vector3i(2, 0, 2)
		# left
		return Vector3i(0, 0, 1)
	elif top_n:
		# top
		return Vector3i(0, 0, 2)
	# none
	return Vector3i(4, 0, 0)
