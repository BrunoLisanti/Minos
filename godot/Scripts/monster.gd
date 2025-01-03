extends CharacterBody3D

const wander_speed: float = 3.8
const chase_speed: float = 3.8
const detection_radius: float = 20.0
const fov: float = 180
var knows_your_position: bool = false
const min_sound_distance: float = 18 # A partir de qué distancia se empieza a escuchar el ruido
const max_sound_distance: float = 4 # Punto en el que el ruido es más fuerte

var speed := wander_speed

@onready var head: Node3D = $"Model/Face"
@onready var movement_component: MovementComponent = $MovementComponent
@onready var pathfinding_component: PathfindingComponent = $PathfindingComponent
@onready var danger: AudioStreamPlayer3D = $Danger

@export var navigation: NavigationRegion3D
@export var prey: Node
@export var debug: Node

func _ready():
	randomize()
	pathfinding_component.init(navigation, debug)
	#danger.volume_db = 0
	#danger.play()

#func _process(_delta: float)->void:
	#danger.volume_db = linear_to_db(clamp(remap(global_position.distance_to(prey.global_position), min_sound_distance, max_sound_distance, 0, 1), 0, 1)) # Mapeamos la distancia entre el jugador y el monstruo a un valor entre 0 y 1 para pasárselo a linear_to_db.

func move_towards(where: Vector3, delta: float)->void:
	movement_component.move(position.direction_to(where), speed, 8, false, delta)
	
	# Mirar hacia esa dirección
	var angle: float = Vector2(global_transform.origin.z, global_transform.origin.x).angle_to_point(Vector2(where.z, where.x))
	set_rotation(Vector3(0, lerp_angle(get_rotation().y, angle, 2.2 * delta), 0))

func can_see(object: CollisionObject3D, offset: Vector3 = Vector3.ZERO)->bool:
	var pointer := Vector3(object.global_position - global_position).normalized()
	var cosine_of_angle_to_object: float = basis.z.dot(pointer) # el producto escalar de dos vectores normalizados es igual al coseno del ángulo entre ellos.
	if cosine_of_angle_to_object < cos(deg_to_rad(fov / 2)): return false
	
	# verificar si hay una pared entre ellos
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var raycast_query = PhysicsRayQueryParameters3D.create(head.global_position, object.global_position + offset)
	raycast_query.exclude = [get_rid(), object.get_rid()] # No es necesario excluir también el KillArea porque por defecto PhysicsRayQueryParameters3D no toma en consideración los nodos Area3D.
	return space.intersect_ray(raycast_query).is_empty()

func _on_memory_timeout():
	knows_your_position = false

func _on_kill_area_body_entered(_body: Node3D) -> void: # Solo el jugador puede entrar en este Area3D por cómo tiene configurada la capa y máscara de colisión.
	get_tree().reload_current_scene()
