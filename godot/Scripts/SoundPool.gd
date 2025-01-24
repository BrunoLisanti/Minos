extends Node

var sounds: Array
var next_sound: int

# Called when the node enters the scene tree for the first time.
func _ready():
	for sound in get_children():
		sounds.append(sound)
	next_sound = randi_range(0, sounds.size() - 1)

func play(avoid_repetition: bool = true):
	var i := next_sound
	sounds[i].play()
	
	next_sound = randi_range(0, sounds.size() - 1)
	if avoid_repetition and sounds.size() > 1:
		while (next_sound == i): next_sound = randi_range(0, sounds.size() - 1)

func relocate(pos: Vector3)->void:
	sounds[next_sound].global_position = pos
	
func get_next_sound():
	return sounds[next_sound]
