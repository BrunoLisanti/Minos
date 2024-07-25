extends CharacterBody3D


const SPEED = 4.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003

#bob variables
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

var gravity = 9.8

@onready var head = $Head
@onready var camera = $Head/Camera3D

#func _ready():
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#func _unhandled_input(event): #Movimiento de camara
	#if event is InputEventMouseMotion:
		#
		#head.rotate_y(-event.relative.x * SENSITIVITY)
		#camera.rotate_x(-event.relative.y * SENSITIVITY) #Mover verticalmente la camara
		#camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60)) #Limitar el movimiento vertical de la camara

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("rotate_right"):
		head.rotate_y(-SENSITIVITY * 10)
	
	if Input.is_action_pressed("rotate_left"):
		head.rotate_y(SENSITIVITY * 10)
		
	# Get the input direction and handle the movement/deceleration.
	# Movimiento en el eje Z de acuerdo a la dirección en la que se está mirando.
	var input_dir = (1 if Input.is_action_pressed("down") else 0) - (1 if Input.is_action_pressed("up") else 0) # 1 si se presiona abajo, -1 si se presiona arriba. Cero si se presionan ambos.
	var direction = (head.transform.basis * Vector3(0, 0, input_dir)).normalized()
	var current_speed = SPEED if input_dir == -1 else SPEED / 2
	
	velocity.x = lerp(velocity.x, direction.x * current_speed, delta * 6.0)
	velocity.z = lerp(velocity.z, direction.z * current_speed, delta * 6.0)
		
	# Head bobbing
	#t_bob += delta * velocity.length() * float(is_on_floor())
	#
	#if direction:
		#camera.transform.origin = _headbob(t_bob)
	#else:
		#camera.transform.origin.y = lerp(camera.transform.origin.y, 0.0, 0.1)
	
	move_and_slide()
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	return pos
