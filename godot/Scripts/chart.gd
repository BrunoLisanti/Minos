extends Node3D

@onready var highlights: Node3D = $Highlights

var lights: Array
var area_highlighted: int = 0

func _ready() -> void:
	for light in highlights.get_children():
		lights.push_back(light)
	lights[area_highlighted].visible = true

func highlight(area: int)->void:
	if (area == area_highlighted || area < 0 || area >= lights.size()): return
	lights[area_highlighted].visible = false
	lights[area].visible = true
	area_highlighted = area
