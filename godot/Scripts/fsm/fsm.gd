extends Node

class_name FSM

var states: Dictionary
var state: State

@export var entry_state: String = "Wander"
var agent: Node

func _ready()->void:
	agent = get_parent()
	for s: State in get_children():
		states[s.name] = s
	change_state(entry_state)

func change_state(to: String)->void:
	if (state): state.exit()
	state = states[to]
	state.enter()

func _process(delta: float)->void:
	state.process(delta)

func _physics_process(delta: float)->void:
	state.physics_process(delta)
