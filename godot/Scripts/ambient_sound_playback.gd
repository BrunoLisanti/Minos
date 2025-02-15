extends Node3D

const min_time: float = 80
const max_time: float = 120

@export var player: Node3D
@export var monster: Node3D

@onready var sound_pool: Node = $SoundPool

func _process(_delta: float) -> void:
	if OS.is_debug_build() and Input.is_action_just_pressed("debug_action_2"):
		play_sound_near(player.global_position)

func play_sound_at(pos: Vector3)->void:
	print("* playing event sound at\n\tx=", int(pos.x), ", z=", int(pos.z), "\nplayer at\n\tx=", int(player.global_position.x), ", z=", int(player.global_position.z))
	sound_pool.relocate(pos)
	sound_pool.play()
	
func play_sound_near(pos: Vector3)->void:
	play_sound_at(pos + Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(randf_range(0, 360))) * sound_pool.get_next_sound().max_distance * .3)
	
func _on_timer_timeout() -> void:
	if (monster.get_node("FSM").state.name == "chase"): return
	play_sound_near(player.global_position)
	$Timer.wait_time = randi_range(min_time, max_time)
	$Timer.start()
