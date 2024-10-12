extends State

@onready var fsm: FSM = $"../../FSM"
@onready var monster: CharacterBody3D = $"/root/World/Maze/Monster"
@onready var player: Node3D = $"/root/World/Maze/Player"

const min_idle_time: float = 2
const max_idle_time: float = 6
const min_wander_time: float = 6
const max_wander_time: float = 10
const detection_window: float = 1 # tiempo en que tarda en detectar al jugador una vez que entra en su campo de visión

var idle := true
var behaviour_duration: float
var time_behaving: float # tiempo que estuvo quieto o moviéndose
var time_aware: float # tiempo que tuvo al jugador en su visión

func enter()->void:
	behaviour_duration = randf_range(min_idle_time, max_idle_time)
	time_behaving = 0
	time_aware = 0

func physics_process(delta)->void:
	if (time_behaving > behaviour_duration):
		change_behaviour(!idle)
		
	if !idle:
		if !monster.path.is_empty():
			monster.follow_path(delta)
		else:
			change_behaviour(true)
			monster.set_path(monster.find_random_point(32, player.global_position))
			
	if monster.global_position.distance_to(player.global_position) < monster.detection_radius && monster.can_see(player, player.camera.position):
		time_aware += delta
	else:
		time_aware = 0
	
	time_behaving += delta
	
	super.physics_process(delta)
	
func check_conditions()->void:
	if (time_aware >= detection_window):
		fsm.change_state("Chase")

func change_behaviour(loitering: bool)->void:
	idle = loitering
	behaviour_duration = randf_range(min_idle_time if idle else min_wander_time, max_idle_time if idle else max_wander_time)
	time_behaving = 0
	
