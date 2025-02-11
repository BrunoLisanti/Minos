extends Control

const hints: Array = [
	"Deliver all flowers to the lit mausoleums.",
	"Check your location on the map by holding the [color=red]V[/color] key.",
	"You move slower while carrying the box. Drop it or pick it back up by using the [color=red]F[/color] key.",
	"Stay hidden by peeking around corners using the [color=red]Q[/color] and [color=red]E[/color] keys.",
	"You are more visible in open spaces. Use winding corridors to your advantage."
]

var queue: Array = []

func trigger(hint: int)->void:
	queue.append(hint)

func display(hint: int)->void:
	$Label.text = "[center][color=red]HINT:[/color] %s[/center]" % hints[hint]
	$Label.visible = true

func _process(_delta: float)->void:
	if $Padding.is_stopped() and $Timer.is_stopped() and queue.size() > 0:
		$Timer.start()
		display(queue[0])
		queue.pop_front()

func _on_timer_timeout() -> void:
	$Label.visible = false
	$Padding.start()
