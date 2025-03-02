extends Node3D

@onready var model: Node3D = $BoxModel
@onready var areas: Node3D = $BoxModel/Flowers
var remaining: int
var slots: int
signal flower_removed

func _ready()->void:
	for area in areas.get_children():
		remaining += area.get_child_count()
	slots = remaining
	utility.set_layer_recursively(model, (2**20)/2) # Layer 20 en complemento a dos

func remove_flower(area: int)->bool:
	if (remaining == 0 || area < 0 || area >= areas.get_child_count()): return false
	var group: Node3D = areas.get_children()[area]
	var flower_found = false
	var area_cleared = false
	for child in group.get_children():
		if child.visible:
			child.visible = false
			flower_found = true
			break
		else:
			area_cleared = true # Si en esta area se encontró otra flor que ya fue entregada, significa que con esta ya completamos el area.
	if not flower_found: return false # Sanity check: si no encontró una flor significa que se intentó entregar una flor en una zona que ya fue completada.
	remaining -= 1
	$Removed.play()
	flower_removed.emit()
	return area_cleared

func get_remaining()->int:
	return remaining
