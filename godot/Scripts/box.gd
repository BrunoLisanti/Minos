extends RigidBody3D
var _is_on_floor := false
@onready var fall_sound := $FallSound
@onready var map := get_parent()
@onready var model: Node3D = $BoxModel

func _on_body_entered(body: Node) -> void:
	if !body.is_in_group("wall"):
		fall_sound.play(false)
		
func is_on_floor() -> bool:
	return _is_on_floor

func _on_fall_sound_finished() -> void:
	_is_on_floor = true
