extends TileMapLayer

var start_drawing_position : Vector2i


func _unhandled_input(event: InputEvent) -> void:
	var mouse_position: Vector2i = local_to_map(get_local_mouse_position())

	if event.is_action_pressed("place"):
		start_drawing_position = mouse_position
	if event.is_action_released("place"):
		var distance_2d : Vector2i = mouse_position - start_drawing_position
		var lenghter : int = maxi(absi(distance_2d.x), absi(distance_2d.y))

		for i : int in range(0, absi(lenghter) + 1):
			var direction : Vector2i = distance_2d.sign()
			var new_cell_pos := Vector2i(
					clampi(start_drawing_position.x + (i * direction.x),
							mini(start_drawing_position.x, mouse_position.x),
							maxi(start_drawing_position.x, mouse_position.x)
					),
					clampi(start_drawing_position.y + (i * direction.y),
							mini(start_drawing_position.y, mouse_position.y),
							maxi(start_drawing_position.y, mouse_position.y)
					)
			)
			set_cell(new_cell_pos, 0, Vector2i(0,0), 0)

	if event.is_action_pressed("destroy"):
		erase_cell(mouse_position)
