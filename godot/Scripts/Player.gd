extends CharacterBody3D


const SPEED := 4.0
const JUMP_VELOCITY := 4.5
const SENSITIVITY := 0.030

#bob variables
const BOB_FREQ := 3.4
const BOB_AMP_HORIZONTAL := 0.01
const BOB_AMP_VERTICAL := 0.005
var t_bob := 0.0

var gravity := 9.8

var step_time: float = 0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera
@onready var footsteps_pool: Node = $FootstepsPool

func _physics_process(delta):	
	var input_rotation = (1 if Input.is_action_pressed("rotate_left") else 0) - (1 if Input.is_action_pressed("rotate_right") else 0) # 0, 1 o -1 de acuerdo a qué teclas estén apretadas.
	rotate_y(input_rotation * SENSITIVITY)
	
	# Movimiento en el eje Z de acuerdo a la dirección en la que se está mirando.
	var input_movement = (1 if Input.is_action_pressed("backward") else 0) - (1 if Input.is_action_pressed("forward") else 0)
	var direction := Vector3(0, 0, input_movement)
	var speed := SPEED if direction == Vector3.FORWARD else SPEED / 2
	velocity = lerp(velocity, transform.basis * direction * speed, delta * 6.0)
	
	var hovering := not is_on_floor()
	var walking := !hovering && direction
	
	if hovering:
		velocity.y -= gravity * delta
	else:
		# pasos
		step_time = step_time + delta if direction else 0
		if (step_time >= 1.75 / speed): # frecuencia de reproducción de sonido de pasos según velocidad
			footsteps_pool.play()
			step_time = 0
	
	# head bobbing
	t_bob += speed * delta # acumulador de tiempo usado como oscilador, y teniendo en cuenta la velocidad (?)
	var bob := Vector3(cos(t_bob * BOB_FREQ / 1.8) * BOB_AMP_HORIZONTAL, sin(t_bob * BOB_FREQ) * BOB_AMP_VERTICAL, 0)
	camera.transform.origin = bob if walking else lerp(camera.transform.origin, Vector3.ZERO, .1)
	
	move_and_slide()
