extends CanvasLayer

@onready var start_btn: Button = find_child("Start")
@onready var options_btn: Button = find_child("Options")
@onready var quit_btn: Button = find_child("Exit")

func _ready() -> void:
	start_btn.pressed.connect(start)
	quit_btn.pressed.connect(get_tree().quit)
	options_btn.pressed.connect(options)
	
func start() -> void:
	get_tree().change_scene_to_file("res://Scenes/world3.tscn")

func options() -> void:
	$Options.visible = !$Options.visible

	
