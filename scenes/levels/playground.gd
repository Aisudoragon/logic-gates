extends Node2D

var previous_tile: Vector2i
var next_wire_list: Array[Vector2i]
@onready var wire_layer: TileMapLayer = $WireLayer
@onready var gate_layer: TileMapLayer = $GateLayer
@onready var highlight_layer: TileMapLayer = $HighlightLayer
@onready var logic_layer: TileMapLayer = $LogicLayer


func _unhandled_input(event: InputEvent) -> void:
	var mouse_position: Vector2i = wire_layer.local_to_map(wire_layer.get_local_mouse_position())

	if event is InputEventMouseButton:
		var event_mb := event as InputEventMouseButton
		if event.is_pressed() and event_mb.button_index == MOUSE_BUTTON_LEFT:
			previous_tile = mouse_position
		if event.is_released() and event_mb.button_index == MOUSE_BUTTON_LEFT:
			copy_highlight_into_layer()

	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not mouse_position == previous_tile:
			var direction: Vector2i = mouse_position - previous_tile
			update_wire_look(previous_tile, direction)
			direction *= -1
			update_wire_look(mouse_position, direction)

			previous_tile = mouse_position
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			highlight_layer.clear()
			update_wire_look(mouse_position, Vector2i.ZERO)

	if Input.is_key_pressed(KEY_1):
		gate_layer.set_cell(mouse_position, 0, Vector2i(0, 0))
		logic_layer.set_cell(mouse_position, 0, Vector2i(0, 0))
	if Input.is_key_pressed(KEY_2):
		gate_layer.set_cell(mouse_position, 0, Vector2i(1, 0), 2)
		logic_layer.set_cell(mouse_position, 0, Vector2i(0, 0))
	if Input.is_key_pressed(KEY_ENTER):
		toogle_start_gate()


func update_wire_look(tile_position: Vector2i, new_direction: Vector2i) -> void:
	var right_direction: bool = false
	var down_direction: bool = false
	var left_direction: bool = false
	var up_direction: bool = false

	var data: TileData = highlight_layer.get_cell_tile_data(tile_position)
	if data:
		if data.get_custom_data("right_direction"):
			right_direction = true
		if data.get_custom_data("down_direction"):
			down_direction = true
		if data.get_custom_data("left_direction"):
			left_direction = true
		if data.get_custom_data("up_direction"):
			up_direction = true
	data = wire_layer.get_cell_tile_data(tile_position)
	if data:
		if data.get_custom_data("right_direction"):
			right_direction = true
		if data.get_custom_data("down_direction"):
			down_direction = true
		if data.get_custom_data("left_direction"):
			left_direction = true
		if data.get_custom_data("up_direction"):
			up_direction = true

	if new_direction == Vector2i.RIGHT:
		right_direction = true
	elif new_direction == Vector2i.DOWN:
		down_direction = true
	elif new_direction == Vector2i.LEFT:
		left_direction = true
	elif new_direction == Vector2i.UP:
		up_direction = true

	if right_direction:
		if down_direction:
			if left_direction:
				if up_direction:
					# right, down, left, top
					highlight_layer.set_cell(tile_position, 0, Vector2i(4, 0), 0)
					return
				# right, down, left
				highlight_layer.set_cell(tile_position, 0, Vector2i(3, 0), 0)
				return
			elif up_direction:
				# right, down, top
				highlight_layer.set_cell(tile_position, 0, Vector2i(3, 0), 3)
				return
			# right, down
			highlight_layer.set_cell(tile_position, 0, Vector2i(2, 0), 0)
			return
		elif left_direction:
			if up_direction:
				# right, left, top
				highlight_layer.set_cell(tile_position, 0, Vector2i(3, 0), 2)
				return
			# right, left
			highlight_layer.set_cell(tile_position, 0, Vector2i(1, 0), 1)
			return
		elif up_direction:
			# right, top
			highlight_layer.set_cell(tile_position, 0, Vector2i(2, 0), 3)
			return
		# right
		highlight_layer.set_cell(tile_position, 0, Vector2i(0, 0), 3)
		return
	elif down_direction:
		if left_direction:
			if up_direction:
				# down, left, top
				highlight_layer.set_cell(tile_position, 0, Vector2i(3, 0), 1)
				return
			# down, left
			highlight_layer.set_cell(tile_position, 0, Vector2i(2, 0), 1)
			return
		elif up_direction:
			# down, top
			highlight_layer.set_cell(tile_position, 0, Vector2i(1, 0), 0)
			return
		# down
		highlight_layer.set_cell(tile_position, 0, Vector2i(0, 0), 0)
		return
	elif left_direction:
		if up_direction:
			# left, top
			highlight_layer.set_cell(tile_position, 0, Vector2i(2, 0), 2)
			return
		# left
		highlight_layer.set_cell(tile_position, 0, Vector2i(0, 0), 1)
		return
	elif up_direction:
		# top
		highlight_layer.set_cell(tile_position, 0, Vector2i(0, 0), 2)
		return
	highlight_layer.set_cell(tile_position, 0, Vector2i(5, 0), 0)


func copy_highlight_into_layer() -> void:
	var all_tiles: Array[Vector2i] = highlight_layer.get_used_cells()

	for coordinates in all_tiles:
		var atlas_coords: Vector2i = highlight_layer.get_cell_atlas_coords(coordinates)
		var alternative: int = highlight_layer.get_cell_alternative_tile(coordinates)

		wire_layer.set_cell(coordinates, 0, atlas_coords, alternative)
		if logic_layer.get_cell_source_id(coordinates) == -1:
			logic_layer.set_cell(coordinates, 0, Vector2i(0, 0))


func toogle_start_gate() -> void:
	var gates: Array[Vector2i] = gate_layer.get_used_cells_by_id(0, Vector2i(0, 0))
	for gate_pos in gates:
		var state: int = logic_layer.get_cell_alternative_tile(gate_pos)
		if state == 0:
			logic_layer.set_cell(gate_pos, 0, Vector2i(0, 0), 1)
		else:
			logic_layer.set_cell(gate_pos, 0, Vector2i(0, 0), 0)
		update_state(gate_pos, state)


func update_state(tile_coords: Vector2i, state: bool) -> void:
	next_wire_list.append(tile_coords)

	for wire_coord in next_wire_list:
		logic_layer.set_cell(wire_coord, 0, Vector2i(0, 0), not state)

		var wire_data: TileData = wire_layer.get_cell_tile_data(wire_coord)
		if wire_data:
			var next_wire := Vector2i.ZERO
			if wire_data.get_custom_data("right_direction"):
				next_wire = wire_coord + Vector2i.RIGHT
				if not next_wire in next_wire_list:
					next_wire_list.append(next_wire)
			if wire_data.get_custom_data("down_direction"):
				next_wire = wire_coord + Vector2i.DOWN
				if not next_wire in next_wire_list:
					next_wire_list.append(next_wire)
			if wire_data.get_custom_data("left_direction"):
				next_wire = wire_coord + Vector2i.LEFT
				if not next_wire in next_wire_list:
					next_wire_list.append(next_wire)
			if wire_data.get_custom_data("up_direction"):
				next_wire = wire_coord + Vector2i.UP
				if not next_wire in next_wire_list:
					next_wire_list.append(next_wire)

	next_wire_list.clear()
