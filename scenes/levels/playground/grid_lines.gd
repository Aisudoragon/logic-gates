extends Node2D


func _draw() -> void:
	var size: Vector2i = get_viewport_rect().size / get_parent().get_node("Camera2D").zoom
	var camera_pos: Vector2i = get_parent().get_node("Camera2D").position
	var min_screen_pos: Vector2i = camera_pos - size / 2
	var max_screen_pos: Vector2i = camera_pos + size / 2
	var grid_color := Color("000", clampf(get_parent().get_node("Camera2D").zoom.x / 2, 0, 1))
	for line in range(min_screen_pos.x / 64, max_screen_pos.x / 64 + 1):
		draw_line(Vector2i(line * 64, min_screen_pos.y), Vector2i(line * 64, max_screen_pos.y), grid_color)
	for line in range(min_screen_pos.y / 64, max_screen_pos.y / 64 + 1):
		draw_line(Vector2i(min_screen_pos.x, line * 64), Vector2i(max_screen_pos.x, line * 64), grid_color)


func _process(delta: float) -> void:
	queue_redraw()
