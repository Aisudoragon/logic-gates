extends Node2D

var startDrawingPos: Vector2i
@onready var wire_grid: TileMapLayer = $WireGrid
@onready var highlight: TileMapLayer = $Highlight


func _unhandled_input(event: InputEvent) -> void:
	var mouse_position: Vector2i = wire_grid.local_to_map(wire_grid.get_local_mouse_position())

	if event.is_action_pressed("place"):
		startDrawingPos = mouse_position

	highlight.clear()

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		draw_wire(startDrawingPos, mouse_position, highlight, 1)
	else:
		highlight.set_cell(mouse_position, 0, Vector2i(0,0), 1)
	if event.is_action_released("place"):
		draw_wire(startDrawingPos, mouse_position, wire_grid, 0)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		wire_grid.set_cell(mouse_position, 0)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var size: Vector2 = get_viewport_rect().size * $Camera2D.zoom / 2
	var cam: Vector2 = $Camera2D.position
	for i in range(int((cam.x - size.x) / 42) - 1, int ((size.x + cam.x) / 42) + 1):
		draw_line(Vector2(i * 42, cam.y + size.y + 100), Vector2(i * 42, cam.y - size.y - 100), "00000030")
	for i in range(int((cam.y - size.y) / 42) - 1, int((size.y + cam.y) / 42) + 1):
		draw_line(Vector2(cam.x + size.x + 100, i * 42), Vector2(cam.x - size.x - 100, i * 42), "00000030")


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
		grid.set_cell(new_cell_pos, 0, Vector2i(0, 0), alt)
