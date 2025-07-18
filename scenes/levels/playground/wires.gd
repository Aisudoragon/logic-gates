class_name Wires extends Node2D

var order_queue: Array[Callable]
var buffer_position: Array[Vector2i]
var rotated: bool = false

@onready var logic_layer: TileMapLayer = $LogicLayer
@onready var wire_layer: TileMapLayer = $WireLayer
@onready var highlight_layer: TileMapLayer = $HighlightLayer
@onready var gate_layer: TileMapLayer = $GateLayer


func _process(_delta: float) -> void:
	if not order_queue.is_empty():
		execute_queue()


func execute_queue() -> void:
	for i in range(1500):
		if order_queue.is_empty():
			return
		var do_now: Callable = order_queue.pop_front()
		if do_now is Callable:
			do_now.callv([])


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
	elif (
			gate_layer.get_cell_source_id(tile_coords) == 0
			and gate_layer.get_cell_atlas_coords(tile_coords) == Vector2i(1, 0)
	):
		#HACK Zrobione na szybko
		if logic_layer.get_cell_alternative_tile(tile_coords) == 0:
			gate_layer.set_cell(tile_coords, 0, Vector2i(1, 0), 1)
		else:
			gate_layer.set_cell(tile_coords, 0, Vector2i(1, 0), 2)

func check_for_wires(tile_coords: Vector2i, state: bool, wire: TileMapLayer,
		logic:  TileMapLayer) -> void:
	var next_step := Callable(self, &"update_wire")

	var wire_data: TileData = wire.get_cell_tile_data(tile_coords)
	if wire_data:
		var next_wire := Vector2i.ZERO
		if wire_data.get_custom_data("right_direction"):
			next_wire = tile_coords + Vector2i.RIGHT
			if (
					wire_layer.get_cell_atlas_coords(next_wire).x > 6
			):
				next_wire = next_wire + Vector2i.RIGHT
			if check_tile_state(next_wire, logic) != state:
				order_queue.append(next_step.bind(next_wire, state, wire, logic))
		if wire_data.get_custom_data("down_direction"):
			next_wire = tile_coords + Vector2i.DOWN
			if (
					wire_layer.get_cell_atlas_coords(next_wire).x > 6
			):
				next_wire = next_wire + Vector2i.DOWN
			if check_tile_state(next_wire, logic) != state:
				order_queue.append(next_step.bind(next_wire, state, wire, logic))
		if wire_data.get_custom_data("left_direction"):
			next_wire = tile_coords + Vector2i.LEFT
			if (
					wire_layer.get_cell_atlas_coords(next_wire).x > 6
			):
				next_wire = next_wire + Vector2i.LEFT
			if check_tile_state(next_wire, logic) != state:
				order_queue.append(next_step.bind(next_wire, state, wire, logic))
		if wire_data.get_custom_data("up_direction"):
			next_wire = tile_coords + Vector2i.UP
			if (
					wire_layer.get_cell_atlas_coords(next_wire).x > 6
			):
				next_wire = next_wire + Vector2i.UP
			if check_tile_state(next_wire, logic) != state:
				order_queue.append(next_step.bind(next_wire, state, wire, logic))
	if wire_layer.get_cell_atlas_coords(tile_coords) == Vector2i(0, 0):
		if check_tile_state(tile_coords, logic_layer) != state:
			order_queue.append(next_step.bind(tile_coords, state, wire_layer, logic_layer))


func toggle_start_gate() -> void:
	var mouse_pos: Vector2i = get_mouse_pos()
	
	if gate_layer.get_cell_atlas_coords(mouse_pos) == Vector2i(0, 0):
		var state := true if gate_layer.get_cell_alternative_tile(mouse_pos) == 1 else false
		gate_layer.set_cell(mouse_pos, 0, Vector2i(0, 0), 2 if state else 1)
		logic_layer.set_cell(mouse_pos, 0, Vector2i(0, 0), 1 if state else 0)
	
		order_queue.append(Callable(self, &"update_wire").bind(mouse_pos, state, wire_layer,
				logic_layer))


func check_tile_state(tile_pos: Vector2i, logic: TileMapLayer) -> bool:
	var logic_data: TileData = logic.get_cell_tile_data(tile_pos)
	if logic_data:
		return logic_data.get_custom_data("state")
	return false


func get_mouse_pos() -> Vector2i:
	return wire_layer.local_to_map(get_local_mouse_position())


func add_checkpoint() -> void:
	buffer_position.append(get_mouse_pos())
	buffer_position.append(get_mouse_pos())

	rotated = false


func rotate_checkpoint() -> void:
	var buff: Vector2i = buffer_position[-1]
	buffer_position[-1] = buffer_position[-2]
	buffer_position[-2] = buff

	rotated = not rotated


func highlight_point() -> void:
	highlight_layer.clear()
	highlight_layer.set_cell(get_mouse_pos(), 0, Vector2i(5, 0), 0)


func highlight_wire() -> void:
	highlight_layer.clear()

	for index in range(0, buffer_position.size(), 2):
		if index == buffer_position.size() - 2:
			if rotated:
				buffer_position[-2] = get_mouse_pos()
			else:
				buffer_position[-1] = get_mouse_pos()

		var starting_position: Vector2i = buffer_position[index]
		var ending_position: Vector2i = buffer_position[index + 1]

		var direction := Vector2i(ending_position - starting_position).sign()

		if direction.y:
			highlight_line(starting_position, Vector2i(starting_position.x, ending_position.y))
		if direction.x:
			highlight_line(Vector2i(starting_position.x, ending_position.y), ending_position)


func highlight_line(starting_position: Vector2i, ending_position: Vector2i) -> void:
	var direction: Vector2i = (ending_position - starting_position).sign()

	if direction.x:
		for variable_position in range(starting_position.x, ending_position.x + direction.x, direction.x):
			if variable_position != starting_position.x:
				update_wire_tile(Vector2i(variable_position, starting_position.y), -direction)
			if variable_position != ending_position.x:
				update_wire_tile(Vector2i(variable_position, starting_position.y), direction)
	else:
		for variable_position in range(starting_position.y, ending_position.y + direction.y, direction.y):
			if variable_position != starting_position.y:
				update_wire_tile(Vector2i(starting_position.x, variable_position), -direction)
			if variable_position != ending_position.y:
				update_wire_tile(Vector2i(starting_position.x, variable_position), direction)


func update_wire_tile(tile_position: Vector2i, new_direction: Vector2i, add: bool = true) -> void:
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
		right_direction = add
	elif new_direction == Vector2i.DOWN:
		down_direction = add
	elif new_direction == Vector2i.LEFT:
		left_direction = add
	elif new_direction == Vector2i.UP:
		up_direction = add

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
	wire_layer.set_cell(tile_position, -1)
	logic_layer.set_cell(tile_position, -1)


func draw_wire() -> void:
	if not buffer_position.is_empty():
		if buffer_position[0] == buffer_position[1]:
			if (
					wire_layer.get_cell_atlas_coords(get_mouse_pos()).x == 3
					or wire_layer.get_cell_atlas_coords(get_mouse_pos()).x == 4
			):
				wire_layer.set_cell(get_mouse_pos(), 0, wire_layer.get_cell_atlas_coords(get_mouse_pos()) + Vector2i(3, 0), wire_layer.get_cell_alternative_tile(get_mouse_pos()))
			elif (
					wire_layer.get_cell_atlas_coords(get_mouse_pos()).x == 6
					or wire_layer.get_cell_atlas_coords(get_mouse_pos()).x == 7
			):
				wire_layer.set_cell(get_mouse_pos(), 0, wire_layer.get_cell_atlas_coords(get_mouse_pos()) - Vector2i(3, 0), wire_layer.get_cell_alternative_tile(get_mouse_pos()))
			buffer_position.clear()
			return

	var all_tiles: Array[Vector2i] = highlight_layer.get_used_cells()

	for coordinates in all_tiles:
		var atlas_coords: Vector2i = highlight_layer.get_cell_atlas_coords(coordinates)
		var alternative: int = highlight_layer.get_cell_alternative_tile(coordinates)

		wire_layer.set_cell(coordinates, 0, atlas_coords, alternative)
		logic_layer.set_cell(coordinates, 0, Vector2i(0, 0), 0)

	buffer_position.clear()
	highlight_layer.clear()


func delete_wire() -> void:
	highlight_layer.clear()
	wire_layer.set_cell(get_mouse_pos(), -1)
	logic_layer.set_cell(get_mouse_pos(), -1)

	for neighbor in wire_layer.get_surrounding_cells(get_mouse_pos()):
		var direction: Vector2i = get_mouse_pos() - neighbor

		update_wire_tile(neighbor, direction, false)

	draw_wire()
	highlight_point()


func highlight_gate() -> void:
	highlight_layer.clear()
	#highlight_layer.set_cell()


func place_gate(gate_selected: EditorMode.Selected) -> void:
	var mouse_pos: Vector2i = get_mouse_pos()
	
	match gate_selected:
		EditorMode.Selected.STARTEND:
			var cell_atlas_coords: Vector2i = gate_layer.get_cell_atlas_coords(mouse_pos)
			if cell_atlas_coords == Vector2i(-1, -1):
				gate_layer.set_cell(mouse_pos, 0, Vector2i(0, 0), 1)
			elif cell_atlas_coords == Vector2i(0, 0):
				gate_layer.set_cell(mouse_pos, 0, Vector2i(1, 0), 1)
			else:
				gate_layer.set_cell(mouse_pos)
		EditorMode.Selected.NOT:
			place_gate_on_layer(1)
		EditorMode.Selected.AND:
			place_gate_on_layer(2)
		EditorMode.Selected.OR:
			place_gate_on_layer(3)
		EditorMode.Selected.NAND:
			place_gate_on_layer(4)
		EditorMode.Selected.NOR:
			place_gate_on_layer(5)
		EditorMode.Selected.XOR:
			place_gate_on_layer(6)
		EditorMode.Selected.XNOR:
			place_gate_on_layer(7)


func place_gate_on_layer(source: int) -> void:
	var mouse_pos: Vector2i = get_mouse_pos()

	if source == 1:
		mouse_pos += Vector2i.DOWN
	gate_layer.set_cell(mouse_pos + Vector2i.UP + Vector2i.LEFT, source, Vector2i(0, 0), 0)
	gate_layer.set_cell(mouse_pos + Vector2i.UP, source, Vector2i(1, 0), 0)
	gate_layer.set_cell(mouse_pos + Vector2i.UP + Vector2i.RIGHT, source, Vector2i(2, 0), 0)
	if source >= 2:
		gate_layer.set_cell(mouse_pos + Vector2i.LEFT, source, Vector2i(0, 1), 0)
		gate_layer.set_cell(mouse_pos, source, Vector2i(1, 1), 0)
		gate_layer.set_cell(mouse_pos + Vector2i.RIGHT, source, Vector2i(2, 1), 0)
		gate_layer.set_cell(mouse_pos + Vector2i.DOWN + Vector2i.LEFT, source, Vector2i(0, 2), 0)
		gate_layer.set_cell(mouse_pos + Vector2i.DOWN, source, Vector2i(1, 2), 0)
		gate_layer.set_cell(mouse_pos + Vector2i.DOWN + Vector2i.RIGHT, source, Vector2i(2, 2), 0)
