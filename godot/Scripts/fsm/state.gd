extends Node

class_name State

@onready var fsm: FSM = get_parent()

func enter()->void:
	pass
	
func exit()->void:
	pass
	
func process(_delta: float)->void:
	check_conditions()

func physics_process(_delta: float)->void:
	check_conditions()

func check_conditions()->void:
	pass
