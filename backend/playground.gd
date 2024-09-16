extends Node2D

@onready var wire_grid: TileMapLayer = $WireGrid
@onready var highlight: TileMapLayer = $Highlight
var startDrawingPos: Vector2i


func _unhandled_input(event: InputEvent) -> void:
	highlight.clear()
	var mouse_position: Vector2i = wire_grid.local_to_map(wire_grid.get_local_mouse_position())

	if event.is_action_pressed("place"):
		startDrawingPos = mouse_position

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		draw_wire(startDrawingPos, mouse_position, highlight, 1)
	else:
		highlight.set_cell(mouse_position, 0, Vector2i(0,0), 1)
	if event.is_action_released("place"):
		draw_wire(startDrawingPos, mouse_position, wire_grid, 0)


func draw_wire(start_pos: Vector2i, end_pos: Vector2i, grid: TileMapLayer, alt: int) -> void:
	var tiles_len : Vector2i = end_pos - start_pos
	var min_pos : Vector2i = start_pos.min(end_pos)
	var max_pos : Vector2i = start_pos.max(end_pos)

	for i in range(0, maxi(absi(tiles_len.x), absi(tiles_len.y)) + 1):
		var direction : Vector2i = tiles_len.sign()
		var new_cell_pos := Vector2i(
				clampi(
						start_pos.x + (i * direction.x),
						min_pos.x,
						max_pos.x
				),
				clampi(
						start_pos.y + (i * direction.y),
						min_pos.y,
						max_pos.y
				)
		)
		grid.set_cell(new_cell_pos, 0 as int, Vector2i(0, 0), alt)
