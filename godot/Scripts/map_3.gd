extends Node3D

@onready var decoration: GridMap = $Lights

func _ready() -> void:
	var faro_simple: int =    decoration.mesh_library.find_item_by_name("faro")
	var faro_doble: int =     decoration.mesh_library.find_item_by_name("faro2")
	var faro_cuadruple: int = decoration.mesh_library.find_item_by_name("faro3")
	for cell in decoration.get_used_cells():
		print(decoration.get_cell_item_orientation(cell))
		var cell_item = decoration.get_cell_item(cell)
		match cell_item:
			faro_simple:
				var instance = preload("res://Scenes/StreetLamp1.tscn").instantiate()
				add_child(instance)
				instance.global_transform.origin = decoration.map_to_local(cell)
				instance.rotation = rot_from_orientation(decoration.get_cell_item_orientation(cell))
			faro_doble:
				var instance = preload("res://Scenes/StreetLamp2.tscn").instantiate()
				add_child(instance)
				instance.global_transform.origin = decoration.map_to_local(cell)
				instance.rotation = rot_from_orientation(decoration.get_cell_item_orientation(cell))
			faro_cuadruple:
				var instance = preload("res://Scenes/StreetLamp3.tscn").instantiate()
				add_child(instance)
				instance.global_transform.origin = decoration.map_to_local(cell)
				instance.rotation = rot_from_orientation(decoration.get_cell_item_orientation(cell))
				
	decoration.clear()

func rot_from_orientation(orientation: int) -> Vector3:
	match orientation:
		0: return Vector3(0, 0, 0)
		22: return Vector3(0, deg_to_rad(90), 0)
		10: return Vector3(0, deg_to_rad(180), 0)
		16: return Vector3(0, deg_to_rad(270), 0)
		_: return Vector3(0, 0, 0)
