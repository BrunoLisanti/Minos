extends RigidBody3D
var _is_on_floor := false
@onready var fall_sound := $FallSound

func _on_body_entered(body: Node) -> void:
	if body.name == "FloorCollision":
		_is_on_floor = true
		fall_sound.play(false)
	
func is_on_floor() -> bool:
	return _is_on_floor
