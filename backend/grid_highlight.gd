extends TileMapLayer

var tile_rotation: int = 0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("rotate"):
		tile_rotation = (tile_rotation + 1) % 4
	
	clear()
	set_cell(local_to_map(to_local(get_viewport().get_mouse_position())), 0,
			Vector2i(0,0), tile_rotation)
