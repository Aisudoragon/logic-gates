extends Node2D

var order_queue: Array[Callable]
var previous_tile: Vector2i
@onready var logic_layer: TileMapLayer = $LogicLayer
@onready var wire_layer: TileMapLayer = $WireLayer
@onready var logic_layer_2: TileMapLayer = $LogicLayer2
@onready var wire_layer_2: TileMapLayer = $WireLayer2
@onready var gate_layer: TileMapLayer = $GateLayer
@onready var highlight_layer: TileMapLayer = $HighlightLayer


func _process(_delta: float) -> void:
	if order_queue.size() != 0:
		execute_queue()


func _unhandled_input(event: InputEvent) -> void:
	var mouse_position: Vector2i = wire_layer.local_to_map(wire_layer.get_local_mouse_position())

	if event.is_action_pressed(&"place"):
		previous_tile = mouse_position
	elif event.is_action_released(&"place"):
		if Input.is_key_pressed(KEY_SHIFT):
			copy_highlight_into_layer(wire_layer_2)
		else:
			copy_highlight_into_layer(wire_layer)
		highlight_layer.clear()
		highlight_layer.set_cell(mouse_position, 0, Vector2i(5, 0), 0)

	if event is InputEventMouseMotion:
		if mouse_position != previous_tile:
			if Input.is_action_pressed(&"place_alt"):
				var direction: Vector2i = mouse_position - previous_tile
				update_wire_look(previous_tile, direction, wire_layer_2)
				direction *= -1
				update_wire_look(mouse_position, direction, wire_layer_2)
			elif Input.is_action_pressed(&"place"):
				var direction: Vector2i = mouse_position - previous_tile
				update_wire_look(previous_tile, direction, wire_layer)
				direction *= -1
				update_wire_look(mouse_position, direction, wire_layer)
			else:
				highlight_layer.clear()
				highlight_layer.set_cell(mouse_position, 0, Vector2i(5, 0), 0)

			previous_tile = mouse_position

	# Input gate
	if Input.is_key_pressed(KEY_0):
		gate_layer.set_cell(mouse_position, 0, Vector2i(0, 0))
		logic_layer.set_cell(mouse_position, 0, Vector2i(0, 0))
	# NOT gate
	elif Input.is_key_pressed(KEY_1):
		place_gate(mouse_position, 1)
	# AND gate
	elif Input.is_key_pressed(KEY_2):
		place_gate(mouse_position, 2)
	# OR gate
	elif Input.is_key_pressed(KEY_3):
		place_gate(mouse_position, 3)
	# NAND gate
	elif Input.is_key_pressed(KEY_4):
		place_gate(mouse_position, 4)
	# NOR gate
	elif Input.is_key_pressed(KEY_5):
		place_gate(mouse_position, 5)
	# XOR gate
	elif Input.is_key_pressed(KEY_6):
		place_gate(mouse_position, 6)
	# XNOR gate
	elif Input.is_key_pressed(KEY_7):
		place_gate(mouse_position, 7)

	elif Input.is_key_pressed(KEY_ENTER):
		toogle_start_gates()
	elif Input.is_key_pressed(KEY_TAB) and gate_layer.get_cell_source_id(mouse_position) == 0:
		var tile_state: bool = check_tile_state(mouse_position, logic_layer)
		if tile_state == false:
			logic_layer.set_cell(mouse_position, 0, Vector2i(0, 0), 1)
		else:
			logic_layer.set_cell(mouse_position, 0, Vector2i(0, 0), 0)

		order_queue.append(Callable(self, &"update_wire").bind(mouse_position, not tile_state,
				wire_layer, logic_layer))


func place_gate(mouse_position: Vector2i, source: int) -> void:
	wire_layer.set_cell(mouse_position + Vector2i.RIGHT, 0, Vector2i(0, 0), 3)
	wire_layer.set_cell(mouse_position + (Vector2i.RIGHT * 2), 0, Vector2i(0, 0), 1)

	if source == 1:
		mouse_position += Vector2i.DOWN
	gate_layer.set_cell(mouse_position + Vector2i.UP + Vector2i.LEFT, source, Vector2i(0, 0), 0)
	gate_layer.set_cell(mouse_position + Vector2i.UP, source, Vector2i(1, 0), 0)
	gate_layer.set_cell(mouse_position + Vector2i.UP + Vector2i.RIGHT, source, Vector2i(2, 0), 0)
	if source >= 2:
		gate_layer.set_cell(mouse_position + Vector2i.LEFT, source, Vector2i(0, 1), 0)
		gate_layer.set_cell(mouse_position, source, Vector2i(1, 1), 0)
		gate_layer.set_cell(mouse_position + Vector2i.RIGHT, source, Vector2i(2, 1), 0)
		gate_layer.set_cell(mouse_position + Vector2i.DOWN + Vector2i.LEFT, source, Vector2i(0, 2), 0)
		gate_layer.set_cell(mouse_position + Vector2i.DOWN, source, Vector2i(1, 2), 0)
		gate_layer.set_cell(mouse_position + Vector2i.DOWN + Vector2i.RIGHT, source, Vector2i(2, 2), 0)


func execute_queue() -> void:
	while order_queue.size() != 0:
		var do_now: Callable = order_queue.pop_front()
		if do_now is Callable:
			do_now.callv([])


func update_wire_look(tile_position: Vector2i, new_direction: Vector2i, wire: TileMapLayer) -> void:
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
	data = wire.get_cell_tile_data(tile_position)
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


func copy_highlight_into_layer(wire: TileMapLayer) -> void:
	var all_tiles: Array[Vector2i] = highlight_layer.get_used_cells()

	for coordinates in all_tiles:
		var atlas_coords: Vector2i = highlight_layer.get_cell_atlas_coords(coordinates)
		var alternative: int = highlight_layer.get_cell_alternative_tile(coordinates)

		wire.set_cell(coordinates, 0, atlas_coords, alternative)


func toogle_start_gates() -> void:
	var gates: Array[Vector2i] = gate_layer.get_used_cells_by_id(0, Vector2i(0, 0))
	for gate_pos in gates:
		var tile_state: bool = check_tile_state(gate_pos, logic_layer)
		if tile_state == false:
			logic_layer.set_cell(gate_pos, 0, Vector2i(0, 0), 1)
		else:
			logic_layer.set_cell(gate_pos, 0, Vector2i(0, 0), 0)

		order_queue.append(Callable(self, &"update_wire").bind(gate_pos, not tile_state, wire_layer,
				logic_layer))


func update_wire(tile_coords: Vector2i, state: bool, wire: TileMapLayer, logic: TileMapLayer) -> void:
	logic.set_cell(tile_coords, 0, Vector2i(0, 0), state)

	check_for_gate(tile_coords)
	check_for_wires(tile_coords, state, wire, logic)


func evaluate_gate(tile_coords: Vector2i) -> void:
	var input_1: bool = check_tile_state(tile_coords, logic_layer)
	var gate_data: TileData = gate_layer.get_cell_tile_data(tile_coords)
	if gate_data:
		var other_coords: Vector2i = gate_data.get_custom_data("other_input_coords")
		var input_2: bool = check_tile_state(tile_coords + other_coords, logic_layer)
		var output_coords: Vector2i = tile_coords + gate_data.get_custom_data("output_coords")

		var output: bool
		# NOT
		if gate_layer.get_cell_source_id(tile_coords) == 1:
			output = not input_1
		# AND
		elif gate_layer.get_cell_source_id(tile_coords) == 2:
			output = input_1 and input_2
		# OR
		elif gate_layer.get_cell_source_id(tile_coords) == 3:
			output = input_1 or input_2
		# NAND
		elif gate_layer.get_cell_source_id(tile_coords) == 4:
			output = not (input_1 and input_2)
		# NOR
		elif gate_layer.get_cell_source_id(tile_coords) == 5:
			output = not (input_1 or input_2)
		# XOR
		elif gate_layer.get_cell_source_id(tile_coords) == 6:
			output = (input_1 and not input_2) or (not input_1 and input_2)
		# XNOR
		elif gate_layer.get_cell_source_id(tile_coords) == 7:
			output = true if input_1 == input_2 else false

		order_queue.append(Callable(self, &"update_wire").bind(output_coords, output, wire_layer,
				logic_layer))


func check_for_gate(tile_coords: Vector2i) -> void:
	if (
			gate_layer.get_cell_source_id(tile_coords) >= 1
			and (gate_layer.get_cell_atlas_coords(tile_coords) == Vector2i(0, 0)
					or gate_layer.get_cell_atlas_coords(tile_coords) == Vector2i(0, 2)
			)
	):
		order_queue.append(Callable(self, &"evaluate_gate").bind(tile_coords))


func check_for_wires(tile_coords: Vector2i, state: bool, wire: TileMapLayer,
		logic:  TileMapLayer) -> void:
	var next_step := Callable(self, &"update_wire")

	var wire_data: TileData = wire.get_cell_tile_data(tile_coords)
	if wire_data:
		var next_wire := Vector2i.ZERO
		if wire_data.get_custom_data("right_direction"):
			next_wire = tile_coords + Vector2i.RIGHT
			if check_tile_state(next_wire, logic) != state:
				order_queue.append(next_step.bind(next_wire, state, wire, logic))
		if wire_data.get_custom_data("down_direction"):
			next_wire = tile_coords + Vector2i.DOWN
			if check_tile_state(next_wire, logic) != state:
				order_queue.append(next_step.bind(next_wire, state, wire, logic))
		if wire_data.get_custom_data("left_direction"):
			next_wire = tile_coords + Vector2i.LEFT
			if check_tile_state(next_wire, logic) != state:
				order_queue.append(next_step.bind(next_wire, state, wire, logic))
		if wire_data.get_custom_data("up_direction"):
			next_wire = tile_coords + Vector2i.UP
			if check_tile_state(next_wire, logic) != state:
				order_queue.append(next_step.bind(next_wire, state, wire, logic))
	if wire_layer.get_cell_atlas_coords(tile_coords) == Vector2i(0, 0):
		if check_tile_state(tile_coords, logic_layer) != state:
			order_queue.append(next_step.bind(tile_coords, state, wire_layer, logic_layer))
	if wire_layer_2.get_cell_atlas_coords(tile_coords) == Vector2i(0, 0):
		if check_tile_state(tile_coords, logic_layer_2) != state:
			order_queue.append(next_step.bind(tile_coords, state, wire_layer_2, logic_layer_2))


func check_tile_state(tile_pos: Vector2i, logic: TileMapLayer) -> bool:
	var logic_data: TileData = logic.get_cell_tile_data(tile_pos)
	if logic_data:
		return logic_data.get_custom_data("state")
	return false
