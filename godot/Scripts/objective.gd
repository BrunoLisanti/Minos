extends StaticBody3D

var active := true

func use():
	active = false
	$Flower.visible = true
