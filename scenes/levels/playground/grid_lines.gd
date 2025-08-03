extends Node2D

@export var camera_2d: Camera2D


func _draw() -> void:
	var size: Vector2i = get_viewport_rect().size / camera_2d.zoom
	var camera_pos: Vector2i = camera_2d.position
	var min_screen_pos: Vector2i = camera_pos - size / 2
	var max_screen_pos: Vector2i = camera_pos + size / 2
	var grid_color := Color("000", clampf(camera_2d.zoom.x / 4, 0, 1))
	for line in range(min_screen_pos.x / 64, max_screen_pos.x / 64 + 1):
		draw_line(Vector2i(line * 64, min_screen_pos.y), Vector2i(line * 64, max_screen_pos.y), grid_color)
	for line in range(min_screen_pos.y / 64, max_screen_pos.y / 64 + 1):
		draw_line(Vector2i(min_screen_pos.x, line * 64), Vector2i(max_screen_pos.x, line * 64), grid_color)


func _process(_delta: float) -> void:
	queue_redraw()
