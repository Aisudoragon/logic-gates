extends TileMapLayer

var tile_rotation: int = 0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("place"):
		set_cell(local_to_map(to_local((event as InputEventMouseButton).position)), 0,
				Vector2i(0,0), tile_rotation)
	
	if event.is_action_pressed("destroy"):
		erase_cell(local_to_map(to_local((event as InputEventMouseButton).position)))
	
	if event.is_action_pressed("rotate"):
		tile_rotation = (tile_rotation + 1) % 4
