extends Label

func _process(_delta):
	var time_left = snapped($EtherTimer.time_left,0.1)
	text = str(time_left)
	
	if time_left <= 0. :
		set("theme_override_colors/font_color",Color(1.0,0.0,0.0,1.0))
		$AnimationPlayer.play("timerlabel")
	else : 
		set("theme_override_colors/font_color",Color(1.0,1.0,1.0,1.0))
		$AnimationPlayer.stop()
