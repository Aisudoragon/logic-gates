extends CanvasLayer

signal mode_selected(mode: EditorMode.Selected)


func _on_select_things_pressed() -> void:
	mode_selected.emit(EditorMode.Selected.SELECT)


func _on_draw_wire_pressed() -> void:
	mode_selected.emit(EditorMode.Selected.WIRE)
