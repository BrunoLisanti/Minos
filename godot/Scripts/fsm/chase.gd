extends State

var monster: CharacterBody3D
var player: CharacterBody3D
var memory: Timer
var target: Vector3

@onready var run: AudioStreamPlayer = $"../../Run"

func enter()->void:
	print("Entered chase")
	monster = fsm.agent
	player = monster.prey
	memory = monster.get_node("Memory")
	monster.knows_your_position = true
	monster.speed = monster.chase_speed
	run.play()
	
func exit()->void:
	pass #print("Exited chase")

func physics_process(delta)->void:
	if player.detectable and monster.knows_your_position:
		target = player.global_transform.origin
		monster.pathfinding_component.set_path(target, false)
	monster.move_towards(monster.pathfinding_component.get_next_point(), delta)
	
	super.physics_process(delta)

func check_conditions()->void:
	if monster.can_see(player, player.head.position):
		monster.knows_your_position = true
		memory.stop()

	if !monster.can_see(player, player.head.position) && monster.knows_your_position:
		if memory.is_stopped():
			memory.start(3)
	
	if !monster.knows_your_position && monster.pathfinding_component.path.is_empty():
		run.stop()
		fsm.change_state("Wander")
		return
