class_name WireLogic
extends Node2D

var buffer_position: Array[Vector2i]
var rotated: bool = false

@onready var logic_layer: TileMapLayer = $LogicLayer
@onready var wire_layer: TileMapLayer = $WireLayer
@onready var highlight_layer: TileMapLayer = $HighlightLayer


func add_checkpoint(mouse_position: Vector2i) -> void:
	buffer_position.append(mouse_position)
	buffer_position.append(mouse_position)

	rotated = false


func rotate_checkpoint() -> void:
	var buff: Vector2i = buffer_position[-1]
	buffer_position[-1] = buffer_position[-2]
	buffer_position[-2] = buff

	rotated = not rotated


func highlight_point(mouse_position: Vector2i) -> void:
	highlight_layer.clear()
	highlight_layer.set_cell(mouse_position, 0, Vector2i(5, 0), 0)


func highlight_wire(mouse_position: Vector2i) -> void:
	highlight_layer.clear()

	for index in range(0, buffer_position.size(), 2):
		if index == buffer_position.size() - 2:
			if rotated:
				buffer_position[-2] = mouse_position
			else:
				buffer_position[-1] = mouse_position

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


func delete_wire(delete_position: Vector2i) -> void:
	highlight_layer.clear()
	wire_layer.set_cell(delete_position, -1)
	logic_layer.set_cell(delete_position, -1)

	for neighbor in wire_layer.get_surrounding_cells(delete_position):
		var direction: Vector2i = delete_position - neighbor

		update_wire_tile(neighbor, direction, false)

	draw_wire()
	highlight_point(delete_position)
