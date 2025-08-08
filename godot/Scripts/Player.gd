extends CharacterBody3D

# Movimiento
const SPEED := 4.0
const sensitivity: float = 0.003
const turn_speed: float = 2.2
var speed_multiplier := 1.0
var sensitivity_multiplier := 1.0

# Head bobbing
const BOB_FREQ := 3.4
const BOB_AMP_HORIZONTAL := 0.01
const BOB_AMP_VERTICAL := 0.005
var t_bob := 0.0

# Pasos
var step_time: float = 0

const max_lean_distance: float = .75

var can_pause := true

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Vision/Camera
@onready var box: Resource = preload("res://Scenes/box.tscn")
@onready var viewmodel_camera: Camera3D = $Control/BoxViewportContainer/SubViewport/BoxCamera
@onready var box_viewmodel: Node3D = $Head/Viewmodel/BoxViewmodel
@onready var footsteps_pool: Node = $FootstepsPool
@onready var vision_raycast: RayCast3D = $VisionRaycast
@onready var interaction_range: Area3D = $InteractionArea
@onready var world: Node = get_parent()
@onready var chart: Node3D = $Head/Viewmodel/ChartAnchor/Chart

@onready var movement_component: MovementComponent = $MovementComponent

@onready var hint_component = get_parent().get_node("HintComponent")

var carrying: bool = true
var box_drop_distance: float = 1

@onready var viewmodel: Node3D = $Head/Viewmodel
@onready var viewmodel_y_origin: float = viewmodel.position.y

var lean_raycast: RayCast3D

var current_area: int

var detectable := true
var cheating_needle := false

@export var monster: Node3D

func _ready()->void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	lean_raycast = RayCast3D.new()
	lean_raycast.position = head.position
	add_child(lean_raycast)
	box_viewmodel.visible = carrying
	sensitivity_multiplier = $CanvasLayer/PauseMenu/Options.sensitivity_slider.value
	
	await get_tree().create_timer(4).timeout
	hint_component.enqueue("Deliver all flowers to the lit mausoleums. Move with WASD and use the mouse to look around.")
	hint_component.enqueue("Check your location on the map by holding the [color=red]V[/color] key. Areas that you've completed will be crossed out.")

func _process(_delta):
	viewmodel_camera.global_transform = head.global_transform
	viewmodel.position.y = viewmodel_y_origin + clamp(-head.rotation.x * .25, -1, .05)
	
	if global_position.z > 0:
		current_area = 2 if global_position.x < 0 else 3
	else:
		current_area = 0 if global_position.x < 0 else 1
		
	chart.highlight(current_area)
	
	if Input.is_action_just_pressed("interact"):
		if !carrying:
			for body in interaction_range.get_overlapping_bodies():
				if (body.is_in_group("pickable") and body.is_on_floor()):
					body.queue_free()
					carrying = true
					break
		else:
			var box_instance: Node = box.instantiate()
			world.add_child(box_instance)
			vision_raycast.target_position = Vector3(0, 0, -box_drop_distance)
			vision_raycast.force_raycast_update()
			box_instance.global_position = global_position + Vector3.UP + -transform.basis.z if not vision_raycast.is_colliding() else vision_raycast.get_collision_point()
			box_instance.rotation = rotation
			
			var dupe = box_viewmodel.model.duplicate() # Copiamos cómo se ve la caja actualmente
			
			utility.set_layer_recursively(dupe, 1) # Colocamos todos sus meshes en layer 1 para que no se vea a través de las paredes como el viewmodel
			box_instance.model.queue_free()
			box_instance.add_child(dupe)
			
			var beacon: OmniLight3D = OmniLight3D.new()
			beacon.light_color = Color.WHITE
			beacon.light_energy = .10
			beacon.light_size = .1
			beacon.position.y = .5
			box_instance.add_child(beacon)
			
			carrying = false
			
		box_viewmodel.visible = carrying
		
	if OS.is_debug_build():
		if Input.is_action_just_pressed("debug_action_1"):
			if (camera.current):
				$Head/Vision/TopCamera.make_current()
			else:
				camera.make_current()
		elif Input.is_action_just_pressed("debug_action_3"):
			detectable = not detectable
			print("player is ", ("not " if not detectable else ""), "detectable")
		elif Input.is_action_just_pressed("debug_action_4"):
			update_objectives()
		elif Input.is_action_just_pressed("debug_action_5"):
			cheating_needle = not cheating_needle
		elif Input.is_action_just_pressed("debug_action_6"):
			speed_multiplier = 1.0 if speed_multiplier > 1.0 else 3.0

func _input(event: InputEvent)->void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity * sensitivity_multiplier)
		head.rotate_x(-event.relative.y * sensitivity * sensitivity_multiplier)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta):
	chart.position.y = lerp(chart.position.y, -1.0 if !Input.is_action_pressed("open_map") else 0.0, 20 * delta)
	#brujula.position.y = lerp(brujula.position.y, -1.0 if !Input.is_action_pressed("open_map") else -0.17, 20 * delta)
	if not cheating_needle:
		chart.rotate_needle_to(-rotation.y, delta)
	else:
		var closest_objective: Node3D = utility.get_closest(get_tree(), global_position, "objective")
		if closest_objective != null:
			var direction: Vector3 = global_position.direction_to(closest_objective.global_position).rotated(Vector3.UP, -rotation.y)
			chart.rotate_needle_to(atan2(direction.x, direction.z), delta)
	
	var x_direction := int(Input.get_axis("strafe_left", "strafe_right"))
	var z_direction := int(Input.get_axis("forward", "backward"))
	var direction := Vector3(x_direction, 0, z_direction).normalized()

	var lean_direction := int(Input.get_axis("lean_left","lean_right"))
	lean_raycast.target_position = Vector3(lean_direction * (max_lean_distance + .5), 0, 0)
	lean_raycast.force_raycast_update()
	var lean_distance: float = max_lean_distance if !lean_raycast.is_colliding() else abs(to_local(lean_raycast.get_collision_point()).x) / 4
	head.position.x = lerp(head.position.x, lean_distance * lean_direction, 8 * delta)
	camera.rotation.z = lerp(camera.rotation.z, deg_to_rad(20) * (lean_distance / max_lean_distance) * -lean_direction, 8 * delta)
	
	var speed := (SPEED if !carrying else SPEED / 1.5) * speed_multiplier
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
	box_viewmodel.transform.origin = bob if walking else lerp(box_viewmodel.transform.origin, Vector3.ZERO, .1)

func _unhandled_input(event: InputEvent) -> void:
	if can_pause and event.is_action_pressed("pause"):
		$CanvasLayer/PauseMenu.pause()

func _on_interaction_area_body_entered(body: Node3D)->void:
	if body.is_in_group("objective") && carrying && box_viewmodel.get_remaining() > 0:
		if !body.active: return
		body.use()
		update_objectives()

func _on_box_viewmodel_flower_removed()->void:
	monster.aggression += 1.0/(box_viewmodel.slots - 1)
	#print("monster aggresion level is now ", monster.aggression)

func update_objectives():
	var area_cleared: bool = box_viewmodel.remove_flower(current_area)
	if (area_cleared): chart.check(current_area)
	if (box_viewmodel.get_remaining() == 0):
		# Fin del juego
		var environment: Environment = get_parent().get_node("WorldEnvironment").environment
		environment.background_color = Color.LIGHT_SKY_BLUE
		environment.ambient_light_color = Color.FLORAL_WHITE
		environment.fog_enabled = false
		get_parent().get_node("DirectionalLight3D").visible = true
		
		monster.queue_free()
		get_parent().get_node("AmbientSoundPlayback").queue_free()
		
		await get_tree().create_timer(5).timeout
		$CanvasLayer/EndPopup.enable()
