extends State

var monster: CharacterBody3D
var player: CharacterBody3D
var memory: Timer
var target: Vector3


func enter()->void:
	print("Entered chase")
	monster = fsm.agent
	player = monster.prey
	memory = monster.get_node("Memory")
	monster.knows_your_position = true
	monster.speed = monster.chase_speed
	
func exit()->void:
	print("Exited chase")

func physics_process(delta)->void:
	if monster.knows_your_position:
		target = player.global_transform.origin
		monster.set_path(target, false)
	monster.follow_path(delta)
	
	super.physics_process(delta)

func check_conditions()->void:
	print(memory.time_left)
	if monster.can_see(player, player.head.position):
		monster.knows_your_position = true
		memory.stop()

	if !monster.can_see(player, player.head.position) && monster.knows_your_position:
		if memory.is_stopped():
			memory.start(3)
	
	if !monster.knows_your_position && monster.path.is_empty():
		fsm.change_state("Wander")
		return
