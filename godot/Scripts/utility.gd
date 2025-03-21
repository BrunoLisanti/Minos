class_name utility

static func random_point_in_circle(radius: float)->Vector2:
	var x := randf_range(-radius, radius)
	var y := randf_range(-radius, radius)
	while (sqrt(x**2 + y**2) >= radius):
		x = randf_range(-radius, radius)
		y = randf_range(-radius, radius)
	return Vector2(x, y)

static func set_layer_recursively(parent: Node3D, bitmap: int)->void:
	for child in parent.get_children():
		if child is VisualInstance3D:
			child.layers = bitmap
		else:
			set_layer_recursively(child, bitmap)
