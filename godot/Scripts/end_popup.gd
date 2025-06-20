extends ColorRect

func _on_exit_pressed() -> void:
	print("test")
	get_tree().quit()

func _on_continue_pressed() -> void:
	print("test")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_node("../..").can_pause = true
	get_tree().paused = false
	queue_free()

func enable()->void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_node("../..").can_pause = false
	get_tree().paused = true
	visible = true


func _on_resume_pressed() -> void:
	print("test")
