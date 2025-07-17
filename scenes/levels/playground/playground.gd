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


	#if event.is_action_pressed(&"place"):
		#previous_tile = mouse_position
	#if event.is_action_pressed(&"destroy"):
		#logic_layer.set_cell(mouse_position)
		#wire_layer.set_cell(mouse_position)
		#logic_layer_2.set_cell(mouse_position)
		#wire_layer_2.set_cell(mouse_position)
		#gate_layer.set_cell(mouse_position)
	#elif event.is_action_released(&"place"):
		#if Input.is_key_pressed(KEY_SHIFT):
			#copy_highlight_into_layer(wire_layer_2)
		#else:
			#copy_highlight_into_layer(wire_layer)
		#highlight_layer.clear()
		#highlight_layer.set_cell(mouse_position, 0, Vector2i(5, 0), 0)
#
	#if event is InputEventMouseMotion:
		#if mouse_position != previous_tile:
			#if Input.is_action_pressed(&"place_alt"):
				#var direction: Vector2i = mouse_position - previous_tile
				#update_wire_look(previous_tile, direction, wire_layer_2)
				#direction *= -1
				#update_wire_look(mouse_position, direction, wire_layer_2)
			#elif Input.is_action_pressed(&"place"):
				#var direction: Vector2i = mouse_position - previous_tile
				#update_wire_look(previous_tile, direction, wire_layer)
				#direction *= -1
				#update_wire_look(mouse_position, direction, wire_layer)
			#else:
				#highlight_layer.clear()
				#highlight_layer.set_cell(mouse_position, 0, Vector2i(5, 0), 0)
#
			#previous_tile = mouse_position
#
	## Input gate
	#if Input.is_key_pressed(KEY_0):
		#gate_layer.set_cell(mouse_position, 0, Vector2i(0, 0))
		#logic_layer.set_cell(mouse_position, 0, Vector2i(0, 0))
	## NOT gate
	#elif Input.is_key_pressed(KEY_1):
		#place_gate(mouse_position, 1)
	## AND gate
	#elif Input.is_key_pressed(KEY_2):
		#place_gate(mouse_position, 2)
	## OR gate
	#elif Input.is_key_pressed(KEY_3):
		#place_gate(mouse_position, 3)
	## NAND gate
	#elif Input.is_key_pressed(KEY_4):
		#place_gate(mouse_position, 4)
	## NOR gate
	#elif Input.is_key_pressed(KEY_5):
		#place_gate(mouse_position, 5)
	## XOR gate
	#elif Input.is_key_pressed(KEY_6):
		#place_gate(mouse_position, 6)
	## XNOR gate
	#elif Input.is_key_pressed(KEY_7):
		#place_gate(mouse_position, 7)
#
	#elif Input.is_key_pressed(KEY_ENTER):
		#toogle_start_gates()
	#elif Input.is_key_pressed(KEY_TAB) and gate_layer.get_cell_source_id(mouse_position) == 0:
		#var tile_state: bool = check_tile_state(mouse_position, logic_layer)
		#if tile_state == false:
			#logic_layer.set_cell(mouse_position, 0, Vector2i(0, 0), 1)
		#else:
			#logic_layer.set_cell(mouse_position, 0, Vector2i(0, 0), 0)
#
		#order_queue.append(Callable(self, &"update_wire").bind(mouse_position, not tile_state,
				#wire_layer, logic_layer))


func _on_editor_interface_mode_selected(mode: EditorMode.Selected) -> void:
	mode_selected = mode
