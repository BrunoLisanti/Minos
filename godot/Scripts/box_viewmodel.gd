extends Node3D

@onready var areas: Node3D = $Flowers
var remaining: int

func _ready()->void:
	for area in areas.get_children():
		remaining += area.get_child_count()

func remove_flower(area: int)->bool:
	if (remaining == 0 || area < 0 || area >= areas.get_child_count()): return false
	var group: Node3D = areas.get_children()[area]
	if (group.get_child_count() == 0): return false
	group.get_children()[0].queue_free()
	remaining -= 1
	return group.get_child_count() - 1 == 0 # Se resta 1 porque la cantidad de hijos no se actualiza hasta el final del frame

func get_remaining()->int:
	return remaining
