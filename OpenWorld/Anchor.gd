extends CheckButton

func _unhandled_key_input(event):
	if event.is_action_pressed("Anchor") :
		button_pressed = !button_pressed
