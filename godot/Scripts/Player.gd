extends CharacterBody3D

# Movimiento
const SPEED := 4.0
const SENSITIVITY: float = 2.2

# Head bobbing
const BOB_FREQ := 3.4
const BOB_AMP_HORIZONTAL := 0.01
const BOB_AMP_VERTICAL := 0.005
var t_bob := 0.0

# Pasos
var step_time: float = 0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera
@onready var box: Resource = preload("res://Scenes/Cajon.tscn")
@onready var viewmodel_camera: Camera3D = $Control/BoxViewportContainer/SubViewport/BoxCamera
@onready var box_viewmodel: Node3D = $BoxViewmodel
@onready var footsteps_pool: Node = $FootstepsPool
@onready var floor_raycast: RayCast3D = $FloorRaycast
@onready var interaction_range: Area3D = $InteractionArea
@onready var world: Node = get_parent()

@onready var movement_component: MovementComponent = $MovementComponent

var carrying: bool = false

func _process(_delta):
	viewmodel_camera.global_transform = camera.global_transform
	
	if Input.is_action_just_pressed("interact"):
		if !carrying:
			for body in interaction_range.get_overlapping_bodies():
				if (body.is_in_group("pickable")):
					body.queue_free()
					carrying = true
					break
		else:
			var box_instance: Node = box.instantiate()
			world.add_child(box_instance)
			box_instance.global_position = global_position + Vector3.UP + -transform.basis.z
			box_instance.rotation = rotation
			carrying = false
			
		box_viewmodel.visible = carrying

func _physics_process(delta):	
	var y_rotation := (1 if Input.is_action_pressed("rotate_left") else 0) - (1 if Input.is_action_pressed("rotate_right") else 0) # 0, 1 o -1 de acuerdo a qué teclas estén apretadas.
	rotate_y(y_rotation * SENSITIVITY * delta)
	
	var z_direction := (1 if Input.is_action_pressed("backward") else 0) - (1 if Input.is_action_pressed("forward") else 0)
	var direction := Vector3(0, 0, z_direction)
	var speed := SPEED if !carrying else SPEED / 1.5
	speed = speed if direction == Vector3.FORWARD else speed / 2
	
	var hovering := not is_on_floor()
	var walking := !hovering && direction
	
	movement_component.move(transform.basis * direction, speed, 8, hovering, delta)
	
	# Sonido de los pasos
	if !hovering:
		step_time = step_time + delta if direction else 0
		if (step_time >= 1.75 / speed): # frecuencia de reproducción de sonido de pasos según velocidad
			footsteps_pool.play()
			step_time = 0
	
	# Head bobbing
	t_bob += speed * delta # Acumulador de tiempo usado como oscilador, y teniendo en cuenta la velocidad (?)
	var bob := Vector3(cos(t_bob * BOB_FREQ / 1.8) * BOB_AMP_HORIZONTAL, sin(t_bob * BOB_FREQ) * BOB_AMP_VERTICAL, 0)
	camera.transform.origin = bob if walking else lerp(camera.transform.origin, Vector3.ZERO, .1)

func _on_interaction_area_body_entered(body: Node3D)->void:
	if body.is_in_group("objective") && carrying:
		body.queue_free()
		box_viewmodel.remove_flower()
