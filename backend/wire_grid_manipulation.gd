extends TileMapLayer


func _unhandled_input(event: InputEvent) -> void:
	var mouse_position: Vector2i = local_to_map(get_local_mouse_position())
	
	if event.is_action_pressed("place"):
		set_cell(mouse_position, 1, Vector2i(0,0), 0)
		update_wire_look(mouse_position, true)
	
	if event.is_action_pressed("destroy"):
		erase_cell(mouse_position)
		update_wire_look(mouse_position, false)


func update_wire_look(mouse_position: Vector2i, created: bool) -> void:
	var neighbors: Array[Vector2i] = get_propoer_neighbors(mouse_position)


func get_propoer_neighbors(center: Vector2i) -> Array[Vector2i]:
	return [
		get_neighbor_cell(center, TileSet.CELL_NEIGHBOR_RIGHT_SIDE),
		get_neighbor_cell(center, TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER),
		get_neighbor_cell(center, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE),
		get_neighbor_cell(center, TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER),
		get_neighbor_cell(center, TileSet.CELL_NEIGHBOR_LEFT_SIDE),
		get_neighbor_cell(center, TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER),
		get_neighbor_cell(center, TileSet.CELL_NEIGHBOR_TOP_SIDE),
		get_neighbor_cell(center, TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER),
	]
