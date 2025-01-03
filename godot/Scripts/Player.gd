extends CharacterBody3D

# Movimiento
const SPEED := 4.0
const sensitivity: float = 0.003
const turn_speed: float = 2.2

# Head bobbing
const BOB_FREQ := 3.4
const BOB_AMP_HORIZONTAL := 0.01
const BOB_AMP_VERTICAL := 0.005
var t_bob := 0.0

# Pasos
var step_time: float = 0

const lean_distance: float = .75

const kbm := true

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Vision/Camera
@onready var box: Resource = preload("res://Scenes/Cajon.tscn")
@onready var viewmodel_camera: Camera3D = $Control/BoxViewportContainer/SubViewport/BoxCamera
@onready var box_viewmodel: Node3D = $Head/Viewmodel/BoxViewmodel
@onready var footsteps_pool: Node = $FootstepsPool
@onready var floor_raycast: RayCast3D = $FloorRaycast
@onready var interaction_range: Area3D = $InteractionArea
@onready var world: Node = get_parent()
@onready var chart: Node3D = $Head/Viewmodel/ChartAnchor/Chart

@onready var movement_component: MovementComponent = $MovementComponent

var carrying: bool = false

@onready var viewmodel: Node3D = $Head/Viewmodel
@onready var viewmodel_y_origin: float = viewmodel.position.y

func _ready()->void:
	if kbm: Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta):
	viewmodel_camera.global_transform = camera.global_transform
	viewmodel.position.y = viewmodel_y_origin + clamp(-head.rotation.x * .25, -1, .05)
	
	if global_position.z > 0:
		chart.highlight(2 if global_position.x < 0 else 3)
	else:
		chart.highlight(0 if global_position.x < 0 else 1)
	
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
		
	if OS.is_debug_build():
		if Input.is_action_just_pressed("change_camera"):
			if (camera.current):
				$Head/Vision/TopCamera.make_current()
			else:
				camera.make_current()

func _input(event: InputEvent)->void:
	if kbm and event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		head.rotate_x(-event.relative.y * sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta):
	if kbm:
		var lean_direction := (1 if Input.is_action_pressed("lean_right") else 0) - (1 if Input.is_action_pressed("lean_left") else 0)
		head.position.x = lerp(head.position.x, lean_distance * lean_direction, 20 * delta)
		head.rotation.z = lerp(head.rotation.z, deg_to_rad(20 * -lean_direction), 20 * delta)
	
	chart.position.y = lerp(chart.position.y, -1.0 if !Input.is_action_pressed("open_map") else 0.0, 20 * delta)
	
	var y_rotation := (1 if Input.is_action_pressed("rotate_left") else 0) - (1 if Input.is_action_pressed("rotate_right") else 0) # 0, 1 o -1 de acuerdo a qué teclas estén apretadas.
	rotate_y(y_rotation * turn_speed * delta)
	
	var x_direction: int = 0
	if kbm:
		x_direction = (1 if Input.is_action_pressed("strafe_right") else 0) - (1 if Input.is_action_pressed("strafe_left") else 0)
	var z_direction := (1 if Input.is_action_pressed("backward") else 0) - (1 if Input.is_action_pressed("forward") else 0)
	
	var direction := Vector3(x_direction, 0, z_direction).normalized()
	
	var speed := SPEED if !carrying else SPEED / 1.5
	speed = speed if direction.z <= 0 else speed / 2
	
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
		body.call_deferred("queue_free")
		box_viewmodel.remove_flower()
		if (box_viewmodel.get_remaining() == 0): get_tree().reload_current_scene()
