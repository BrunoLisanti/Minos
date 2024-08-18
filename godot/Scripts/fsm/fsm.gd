extends Node

class_name FSM

var states: Dictionary
var state: State

@export var entry_state: String = "Wander"
@onready var monster: CharacterBody3D = $"/root/World/Maze/Monster"
@onready var player: CharacterBody3D = $"/root/World/Maze/Player"

func _ready()->void:
	for state: State in get_children():
		states[state.name] = state
	change_state(entry_state)

func change_state(to: String)->void:
	if (state): state.exit()
	state = states[to]
	state.enter()

func _process(delta: float)->void:
	state.process(delta)

func _physics_process(delta: float)->void:
	state.physics_process(delta)
