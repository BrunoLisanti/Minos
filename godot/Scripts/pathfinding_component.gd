# https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationservers.html
# https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationpaths.html

extends Node

class_name PathfindingComponent

@export var agent: Node3D

var navigation: NavigationRegion3D
var map: RID

var path: PackedVector3Array
var path_index: int = 0
const path_point_margin: float = 0.5 # margen de diferencia aceptable para poder decir que la entidad se encuentra en un punto determinado

var debug: Node

func init(n: NavigationRegion3D, d: Node):
	navigation = n
	map = navigation.get_navigation_map()
	debug = d

func set_path(to: Vector3, restrictive: bool = true)->void:
	path = NavigationServer3D.map_get_path(map, agent.global_transform.origin, to, !restrictive) # se supone que al usar restrictive se va a mover exclusivamente por el medio de los pasillos. no debería ser el caso cuando está persiguiendo al jugador.
	path_index = 0
	if OS.is_debug_build() and debug != null:
		debug.draw_path(path, Color.BLUE)

func get_next_point()->Vector3:
	if (path.is_empty()): return Vector3.ZERO
	if (agent.global_position.distance_to(path[path_index]) <= path_point_margin):
		path_index += 1
	if (path_index >= path.size()):
		path = []
		path_index = 0
		return Vector3.ZERO
	return path[path_index]

func get_random_point(radius: float, origin: Vector3)->Vector3:
	print("finding random point")
	var x := randf_range(-radius, radius)
	var z := randf_range(-radius, radius)
	while (sqrt(x**2 + z**2) >= radius):
		x = randf_range(-radius, radius)
		z = randf_range(-radius, radius)
	return NavigationServer3D.map_get_closest_point(map, Vector3(origin.x + x, agent.global_position.y, origin.z + z))
