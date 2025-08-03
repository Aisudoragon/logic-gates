class_name WiresInterface extends CanvasLayer

@export var debug_coordinates: Label
@export var debug_zoom_level: Label
@export var debug_queue_size: Label

signal mode_selected(mode: EditorMode.Selected)


func update_coordinates(mouse_pos: Vector2i) -> void:
	debug_coordinates.text = "%d, %d" % [mouse_pos.x, mouse_pos.y]


func update_zoom_level(zoom: float) -> void:
	debug_zoom_level.text = "zoom: %.3f" % zoom


func update_queue_size(size: int) -> void:
	debug_queue_size.text = "%d : queue" % size


func _on_select_things_pressed() -> void:
	mode_selected.emit(EditorMode.Selected.SELECT)


func _on_draw_wire_pressed() -> void:
	mode_selected.emit(EditorMode.Selected.WIRE)


func _on_place_start_end_pressed() -> void:
	mode_selected.emit(EditorMode.Selected.STARTEND)


func _on_place_not_pressed() -> void:
	mode_selected.emit(EditorMode.Selected.NOT)


func _on_place_and_pressed() -> void:
	mode_selected.emit(EditorMode.Selected.AND)


func _on_place_nand_pressed() -> void:
	mode_selected.emit(EditorMode.Selected.NAND)


func _on_place_or_pressed() -> void:
	mode_selected.emit(EditorMode.Selected.OR)


func _on_place_nor_pressed() -> void:
	mode_selected.emit(EditorMode.Selected.NOR)


func _on_place_xor_pressed() -> void:
	mode_selected.emit(EditorMode.Selected.XOR)


func _on_place_xnor_pressed() -> void:
	mode_selected.emit(EditorMode.Selected.XNOR)
