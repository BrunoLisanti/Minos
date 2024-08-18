extends Node

class_name State

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
