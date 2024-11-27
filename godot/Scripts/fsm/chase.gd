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
	if monster.can_see(player, player.head.position):
		#print("Te esta viendo wachin")
		if !memory.is_stopped():
			memory.stop()

	if !monster.can_see(player, player.head.position) && monster.knows_your_position:
		#print("No ve pero recuerda")
		if memory.is_stopped():
			memory.start(3)
	
	if !monster.knows_your_position && monster.path.is_empty():
		#print("Se perdio al monstruo...")
		fsm.change_state("Wander")
		return
