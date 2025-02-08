extends CanvasLayer

@onready var restart_btn: Button = find_child("Restart")
@onready var main_menu_btn: Button = find_child("MainMenu")
@onready var exit_btn: Button = find_child("Exit")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	restart_btn.pressed.connect(restart)
	main_menu_btn.pressed.connect(main_menu)
	exit_btn.pressed.connect(get_tree().quit)

func restart():
	get_tree().change_scene_to_file("res://Scenes/world3.tscn")

func main_menu():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
