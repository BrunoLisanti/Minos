extends State

var monster: CharacterBody3D
var player: CharacterBody3D
var target: Vector3

func enter()->void:
	print("Entered chase")
	monster = fsm.agent
	player = monster.prey
	monster.speed = monster.chase_speed
	
func exit()->void:
	print("Exited chase")

func physics_process(delta)->void:
	if monster.can_see(player, player.head.position):
		target = player.global_transform.origin
		monster.set_path(target, false)
	monster.follow_path(delta)
	
	super.physics_process(delta)
	
func check_conditions()->void:
	if !monster.can_see(player, player.head.position) && monster.path.is_empty():
		fsm.change_state("Wander")
		return
