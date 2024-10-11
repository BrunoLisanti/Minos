extends RayCast3D

var obj = null
@onready var hold_position = $"../HoldPosition"
@onready var camera = $".."
@onready var character = $"../.."


func _process(delta):
	if Input.is_action_just_pressed("interact"):
		if obj == null:
			var collider = get_collider()
			if collider != null:
				if collider.is_in_group("pickable"):
					obj = collider
		else:
			obj = null

	if obj != null:
		obj.global_position = hold_position.global_position
		obj.rotation = character.rotation

