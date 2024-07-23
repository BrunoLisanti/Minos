extends CharacterBody3D


const SPEED = 10.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003

#bob variables
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

var gravity = 9.8

@onready var head = $Head
@onready var camera = $Head/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event): #Movimiento de camara
	if event is InputEventMouseMotion:
		
		head.rotate_y(-event.relative.x * SENSITIVITY)
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
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 2.0)
		camera.transform.origin.y = lerp(camera.transform.origin.y, 0.0, 0.1)	
		
	t_bob += delta * velocity.length() * float(is_on_floor())
	
	if direction:
		camera.transform.origin = _headbob(t_bob)
	else:
		camera.transform.origin.y = lerp(camera.transform.origin.y, 0.0, 0.1)
	
	move_and_slide()
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	return pos
