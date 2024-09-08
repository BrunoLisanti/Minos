extends State

@onready var fsm: FSM = $"../../FSM"

@onready var monster: CharacterBody3D = $"/root/World/Maze/Monster"
@onready var player: Node3D = $"/root/World/Maze/Player"
var target: Vector3

func enter()->void:
	print("Entered chase")
	
func exit()->void:
	print("Exited chase")

func physics_process(delta)->void:
	if monster.can_see(player, player.camera.position):
		target = player.global_transform.origin
		monster.set_path(target, false)
	monster.follow_path(delta)

	super.physics_process(delta)
	
func check_conditions()->void:
	if monster.global_transform.origin.distance_to(target) > monster.detection_radius:
		fsm.change_state("Wander")
		return
	if !monster.can_see(player, player.camera.position) && monster.path.is_empty():
		fsm.change_state("Wander")
		return
