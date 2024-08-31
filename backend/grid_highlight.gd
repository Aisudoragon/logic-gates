extends TileMapLayer


func _unhandled_input(_event: InputEvent) -> void:
	clear()
	set_cell(local_to_map(get_local_mouse_position()), 1, Vector2i(0,0), 0)
