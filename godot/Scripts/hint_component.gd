extends Control

var queue: Array[String]
var displayed: Array[String]

func enqueue(hint: String)->void:
	queue.append(hint)

func display(hint: String)->void:
	$Label.text = "[center][color=red]HINT:[/color] %s[/center]" % hint
	$Label.visible = true

func _process(_delta: float)->void:
	if $Padding.is_stopped() and $Lifetime.is_stopped() and queue.size() > 0:
		$Lifetime.start()
		display(queue[0])
		queue.pop_front()

func _on_timer_timeout() -> void:
	$Label.visible = false
	$Padding.start()
