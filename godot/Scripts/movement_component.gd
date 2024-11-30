extends Node

class_name MovementComponent

@export var body: CharacterBody3D
@export var gravity: float = 9.8

var velocity: Vector3 = Vector3.ZERO

func move(direction: Vector3, max_speed: float, interpolationWeight: float, falling: bool, delta: float)->void:
	velocity = lerp(velocity, direction * max_speed, interpolationWeight * delta)
	if (falling): velocity.y -= gravity * delta
	
	body.velocity = velocity
	body.move_and_slide()
