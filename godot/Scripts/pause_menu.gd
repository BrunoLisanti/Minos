extends ColorRect

@onready var resume_btn: Button = find_child("Resume")
@onready var quit_btn: Button = find_child("Quit")

func _ready() -> void:
	hide()
	resume_btn.pressed.connect(unpause)
	quit_btn.pressed.connect(get_tree().quit)

func unpause():
	hide()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func pause():
	show()
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
