extends State

@onready var fsm: FSM = $"../../FSM"

@onready var monster: CharacterBody3D = $"/root/World/Maze/Monster"
@onready var player: Node3D = $"/root/World/Maze/Player"
var target: Vector3

func enter()->void:
	print("Entered chase")
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
