extends CharacterBody3D

# https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationservers.html
# https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationpaths.html

const speed: float = 120
const detection_radius: float = 20.0
const fov: int = 90

@onready var head: Node3D = $"Model/Face"
@onready var maze: Node3D = $"/root/World/Maze"

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

@onready var debug: Node = $"/root/World/Debug"

func _ready():
	randomize()

func move(where: Vector3, delta)->void:
	velocity = global_position.direction_to(where) * speed * delta
	move_and_slide()
	look_at(where, Vector3.UP, true)
	
func set_path(to: Vector3, restrictive: bool = true)->void:
	path = NavigationServer3D.map_get_path(map, global_transform.origin, to, !restrictive) # se supone que al usar restrictive se va a mover exclusivamente por el medio de los pasillos. no debería ser el caso cuando está persiguiendo al jugador.
	path_index = 0
	if OS.is_debug_build():
		debug.draw_path(path, Color.BLUE)

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
	
	move(destination, delta)

func can_see(object: CollisionObject3D, offset: Vector3 = Vector3.ZERO)->bool:
	var pointer: Vector3 = Vector3(object.global_position - global_position).normalized()
	var cosine_of_angle_to_player: float = basis.z.dot(pointer) # el producto escalar de dos vectores normalizados es igual al coseno del ángulo entre ellos.
	if cosine_of_angle_to_player < cos(deg_to_rad(fov / 2)): return false
	
	# verificar si hay una pared entre ellos
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var raycast_query = PhysicsRayQueryParameters3D.create(head.global_position, object.global_position + offset)
	raycast_query.exclude = [get_rid(), object.get_rid()] # TODO: se está excluyendo el "visor" (cara) del monstruo?
	
	var collision: Dictionary = space.intersect_ray(raycast_query)
	return collision.is_empty()

func find_random_point(radius: float, pos: Vector3)->Vector3:
	print("finding random point")
	var x: float = randf_range(-radius, radius)
	var z: float = randf_range(-radius, radius)
	while (sqrt(x**2 + z**2) >= radius):
		x = randf_range(-radius, radius)
		z = randf_range(-radius, radius)
	return NavigationServer3D.map_get_closest_point(map, Vector3(pos.x + x, global_position.y, pos.z + z))
