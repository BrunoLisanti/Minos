# basado en https://github.com/Ryan-Mirch/Line-and-Sphere-Drawing/blob/main/Draw3D.gd

extends Node

var buffer: Array[MeshInstance3D]

func draw_path(p: PackedVector3Array, color = Color.WHITE_SMOKE)->void:
	for mesh in buffer: # limpiar el dibujo anterior
		if is_instance_valid(mesh):
			mesh.queue_free()
	for i in range(p.size() - 1):
		buffer.append(await draw_line(p[i], p[i + 1], color))

func draw_line(a: Vector3, b: Vector3, color = Color.WHITE_SMOKE, persist_ms = 0):
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()

	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(a)
	immediate_mesh.surface_add_vertex(b)
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color

	return await final_cleanup(mesh_instance, persist_ms)

## 1 -> Lasts ONLY for current physics frame
## >1 -> Lasts X time duration.
## <1 -> Stays indefinitely
func final_cleanup(mesh_instance: MeshInstance3D, persist_ms: float):
	get_tree().get_root().add_child(mesh_instance)
	if persist_ms == 1:
		await get_tree().physics_frame
		mesh_instance.queue_free()
	elif persist_ms > 0:
		await get_tree().create_timer(persist_ms).timeout
		mesh_instance.queue_free()
	else:
		return mesh_instance