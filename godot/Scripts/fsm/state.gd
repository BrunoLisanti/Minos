extends Node

class_name State

@onready var fsm: FSM = get_parent()

func enter()->void:
	pass
	
func exit()->void:
	pass
	
func process(delta: float)->void:
	check_conditions()

func physics_process(delta: float)->void:
	check_conditions()

func check_conditions()->void:
	pass
