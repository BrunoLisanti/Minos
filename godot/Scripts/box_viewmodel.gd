extends Node3D

@onready var flowers: Node3D = $Flowers
var remaining: int

func _ready()->void:
	remaining = flowers.get_children().size()

func remove_flower()->void:
	if (remaining == 0): return
	flowers.get_children()[0].queue_free()
	remaining -= 1
