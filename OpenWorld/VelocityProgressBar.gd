extends ProgressBar

func _process(_delta):
	var vel = %player.velocity
	var norm = (vel.x**2 + vel.y**2)**0.5
	value = (norm / %player.speed)*100.0
