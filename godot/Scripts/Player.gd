extends CharacterBody3D

# Movimiento
const SPEED := 4.0
const SENSITIVITY := 0.030

# Head bobbing
const BOB_FREQ := 3.4
const BOB_AMP_HORIZONTAL := 0.01
const BOB_AMP_VERTICAL := 0.005
var t_bob := 0.0

# Pasos
var step_time: float = 0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera
@onready var footsteps_pool: Node = $FootstepsPool

@onready var movement_component: MovementComponent = $MovementComponent

func _physics_process(delta):	
	var y_rotation := (1 if Input.is_action_pressed("rotate_left") else 0) - (1 if Input.is_action_pressed("rotate_right") else 0) # 0, 1 o -1 de acuerdo a qué teclas estén apretadas.
	rotate_y(y_rotation * SENSITIVITY)
	
	var z_direction := (1 if Input.is_action_pressed("backward") else 0) - (1 if Input.is_action_pressed("forward") else 0)
	var direction := Vector3(0, 0, z_direction)
	var speed := SPEED if direction == Vector3.FORWARD else SPEED / 2
	
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
