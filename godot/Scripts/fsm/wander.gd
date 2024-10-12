extends State

@onready var fsm: FSM = $"../../FSM"
@onready var monster: CharacterBody3D = $"/root/World/Maze/Monster"
@onready var player: Node3D = $"/root/World/Maze/Player"

@onready var targets: Array[Vector3] = [
	$"/root/World/Maze/NavigationRegion3D/Corner".global_transform.origin,
	$"/root/World/Maze/NavigationRegion3D/DeadEnd".global_transform.origin,
	$"/root/World/Maze/NavigationRegion3D/Room".global_transform.origin
]
var target_index: int = 0

const min_idle: float = 2
const max_idle: float = 6
const min_wander: float = 6
const max_wander: float = 10

var idle: bool = true # cada vez que se entra en este estado el monstruo se queda quieto unos segundos.
var duration: float
var elapsed: float = 0

func enter()->void:
	duration = randf_range(min_idle, max_idle)
	target_index = randi_range(0, targets.size() - 1)

func physics_process(delta)->void:
	if (elapsed > duration):
		idle = !idle
		duration = randf_range(min_idle if idle else min_wander, max_idle if idle else max_wander)
		elapsed = 0
		
	if !idle:
		if !monster.path.is_empty():
			monster.follow_path(delta)
		else:
			monster.set_path(monster.find_random_point(32, player.global_position))
			target_index = target_index + 1 if target_index < targets.size() - 1 else 0
	
	elapsed += delta
	
	super.physics_process(delta)
	
func check_conditions()->void:
	if monster.global_position.distance_to(player.global_position) < monster.detection_radius: 
		#print("player in range")
		if monster.can_see(player, player.camera.position):
			fsm.change_state("Chase")
