extends CharacterBody3D

const wander_speed: float = 3.8
const chase_speed: float = 3.8
const detection_radius: float = 20.0
const danger_distance: float = detection_radius * 1.5 # A partir de qué distancia se empieza a escuchar el ruido
const fov: float = 175
var knows_your_position: bool = false
const min_sound_distance: float = 18
var encountered_player: bool = false
var aggression: float = 0 # Valor en el rango [0, 1]

var speed := wander_speed

@onready var head: Node3D = $"Model/Face"
@onready var movement_component: MovementComponent = $MovementComponent
@onready var pathfinding_component: PathfindingComponent = $PathfindingComponent
@onready var danger: AudioStreamPlayer3D = $Danger
@onready var hint_component: Node = get_parent().get_node("HintComponent")

@export var navigation: NavigationRegion3D
@export var prey: Node
@export var debug: Node

func _ready():
	randomize()
	pathfinding_component.init(navigation, debug)
	danger.max_distance = danger_distance

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
	var raycast_query = PhysicsRayQueryParameters3D.create(head.global_position, object.global_position + offset)
	raycast_query.exclude = [get_rid(), object.get_rid()] # No es necesario excluir también el KillArea porque por defecto PhysicsRayQueryParameters3D no toma en consideración los nodos Area3D.
	return get_world_3d().direct_space_state.intersect_ray(raycast_query).is_empty()

func _on_memory_timeout():
	knows_your_position = false

func _on_kill_area_body_entered(_body: Node3D) -> void: # Solo el jugador puede entrar en este Area3D por cómo tiene configurada la capa y máscara de colisión.
	if prey.detectable: get_tree().call_deferred("change_scene_to_file", "res://Scenes/death_screen.tscn")

func _process(_delta: float) -> void:
	if not encountered_player and global_position.distance_to(prey.global_position) <= danger_distance:
		hint_component.enqueue("Stay hidden by peeking around corners using the [color=red]Q[/color] and [color=red]E[/color] keys.")
		hint_component.enqueue("You move slowly while carrying the box. Drop it or pick it back up by using the [color=red]F[/color] key.")
		encountered_player = true

func distance_to_player()->float:
	return global_position.distance_to(prey.global_position)
