extends Node3D

var areas: Array
var area_highlighted: int = 0
@onready var aguja: MeshInstance3D = $Brujula/Aguja


func _ready() -> void:
	for area in $Areas.get_children():
		areas.push_back(area)
	areas[area_highlighted].light.visible = true

func highlight(area: int)->void:
	if (area == area_highlighted || area < 0 || area >= areas.size()): return
	areas[area_highlighted].light.visible = false
	areas[area].light.visible = true
	area_highlighted = area

func check(area: int)->void:
	if area < 0 || area >= areas.size(): return
	areas[area].check.visible = true

func rotate_needle_to(deg: float, delta: float) -> void:
	aguja.set_rotation(Vector3(aguja.rotation.x, deg, aguja.rotation.z))
