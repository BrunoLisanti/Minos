extends Node

var sounds: Array[AudioStreamPlayer]
var last_index: int = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	for sound in get_children():
		sounds.append(sound)

func play(avoid_repetition: bool = true):
	var i := randi_range(0, sounds.size() - 1)
	if avoid_repetition:
		while (i == last_index):
			i = randi_range(0, sounds.size() - 1)
		last_index = i
	sounds[i].play()
