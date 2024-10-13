extends Node3D

@onready var ambient: AudioStreamPlayer = $Ambient

# Called when the node enters the scene tree for the first time.
func _ready():
	ambient.play()
