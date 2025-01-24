class_name utility

static func random_point_in_circle(radius: float)->Vector2:
	var x := randf_range(-radius, radius)
	var y := randf_range(-radius, radius)
	while (sqrt(x**2 + y**2) >= radius):
		x = randf_range(-radius, radius)
		y = randf_range(-radius, radius)
	return Vector2(x, y)
