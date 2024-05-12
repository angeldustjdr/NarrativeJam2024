extends ProgressBar

func _process(_delta):
	var degree = abs(%player.rotation_degrees)
	
	value = degree - int(degree/360.0)*360.

