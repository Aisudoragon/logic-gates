extends Node2D

var mode_selected: EditorMode.Selected = EditorMode.Selected.SELECT
@onready var wires: Wires = $Wires


func _unhandled_input(event: InputEvent) -> void:
	match mode_selected:
		EditorMode.Selected.SELECT:
			if event.is_action_pressed(&"place"):
				wires.toggle_start_gate()
		EditorMode.Selected.WIRE:
			if event.is_action_pressed(&"place") or event.is_action_pressed(&"special"):
				wires.add_checkpoint()
			if event.is_action_pressed(&"rotate"):
				wires.rotate_checkpoint()
				wires.highlight_wire()
			if event.is_action_released(&"place"):
				wires.draw_wire()
			if event.is_action_pressed(&"destroy"):
				wires.delete_wire()

			if event is InputEventMouseMotion:
				if Input.is_action_pressed(&"place"):
					wires.highlight_wire()
				else:
					wires.highlight_point()
				if Input.is_action_pressed(&"destroy"):
					wires.delete_wire()
		_:
			if event.is_action_pressed(&"place"):
				wires.place_gate(mode_selected)

			if event is InputEventMouseMotion:
				wires.highlight_gate()


func _on_editor_interface_mode_selected(mode: EditorMode.Selected) -> void:
	mode_selected = mode
