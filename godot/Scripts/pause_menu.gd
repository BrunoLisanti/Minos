extends ColorRect

@onready var resume_btn: Button = find_child("Resume")
@onready var quit_btn: Button = find_child("Quit")
@onready var main_menu_btn: Button = find_child("MainMenu")
@onready var options_btn: Button = find_child("Options")

func _ready() -> void:
	hide()
	resume_btn.pressed.connect(unpause)
	quit_btn.pressed.connect(get_tree().quit)
	main_menu_btn.pressed.connect(main_menu)
	options_btn.pressed.connect(options)

func main_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func unpause():
	hide()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var player: CharacterBody3D = $"../.."
	if player != null:
		player.sensitivity_multiplier = $Options/PanelContainer/CenterContainer/VBoxContainer/Sensitivity.value

func pause():
	show()
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func options() -> void:
	$Options.visible = !$Options.visible
