extends State

#@onready var fsm: FSM = get_parent()

const min_idle_time: float = 2
const max_idle_time: float = 4
const min_wander_time: float = 6
const max_wander_time: float = 10
const detection_window: float = .25 # tiempo en que tarda en detectar al jugador una vez que entra en su campo de visión
const stalk_radius: float = 25 # radio alrededor del jugador en que busca el próximo punto a moverse

var idle := true
var behaviour_duration: float
var time_behaving: float # tiempo que estuvo quieto o moviéndose
var time_aware: float # tiempo que tuvo al jugador en su visión

var monster: CharacterBody3D
var player: CharacterBody3D
func enter()->void:
	monster = fsm.agent
	player = monster.prey
	monster.knows_your_position = false
	behaviour_duration = randf_range(min_idle_time, max_idle_time)
	time_behaving = 0
	time_aware = 0
	monster.speed = monster.wander_speed

func physics_process(delta)->void:
	if (time_behaving > behaviour_duration):
		change_behaviour(!idle)
		
	if !idle:
		if !monster.pathfinding_component.path.is_empty():
			monster.move_towards(monster.pathfinding_component.get_next_point(), delta)
		else:
			change_behaviour(true)
			monster.pathfinding_component.set_path(monster.pathfinding_component.get_random_point(stalk_radius, player.global_position))
			
	if player.detectable and monster.global_position.distance_to(player.global_position) < monster.detection_radius && monster.can_see(player, Vector3(0, player.head.position.y, 0)):
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
	
