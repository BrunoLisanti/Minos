extends Node3D

# https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationservers.html
# https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationpaths.html

const speed: float = 4.0

@onready var navigation: NavigationRegion3D = $"/root/World/Maze/NavigationRegion3D"
@onready var map: RID = navigation.get_navigation_map()
var path: PackedVector3Array
var path_index: int = 0
const path_point_margin: float = 0.5 # margen de diferencia aceptable para poder decir que la entidad se encuentra en un punto determinado

@onready var targets: Array[Vector3] = [
	$"/root/World/Maze/NavigationRegion3D/Corner".global_transform.origin,
	$"/root/World/Maze/NavigationRegion3D/DeadEnd".global_transform.origin,
	$"/root/World/Maze/NavigationRegion3D/Room".global_transform.origin
]
var target_index: int = 0

func _ready()->void:
	call_deferred("navigation_init")

func navigation_init()->void:
	await get_tree().physics_frame # requisito para usar NavigationServer3D
	set_path(targets[target_index])

func _physics_process(delta)->void:
	if !path.is_empty(): 
		follow_path(delta)
	else:
		target_index = target_index + 1 if target_index < targets.size() - 1 else 0
		set_path(targets[target_index])
	
func set_path(to: Vector3, restrictive: bool = true)->void:
	path = NavigationServer3D.map_get_path(map, global_transform.origin, to, !restrictive) # se supone que al usar restrictive se va a mover exclusivamente por el medio de los pasillos. no debería ser el caso cuando está persiguiendo al jugador.

func follow_path(delta)->void:
	var start: Vector3 = global_transform.origin
	var destination: Vector3 = path[path_index]
	if start.distance_to(destination) <= path_point_margin:
		path_index += 1
		if (path_index >= path.size()):
			path = []
			path_index = 0
			return
		destination = path[path_index]
	
	var velocity: Vector3 = start.direction_to(destination) * speed * delta
	global_transform.origin = start.move_toward(start + velocity, speed * delta)
