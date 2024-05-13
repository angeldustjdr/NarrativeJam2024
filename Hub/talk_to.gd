extends Button

var talk_to = ""

func _on_pressed():
	Radio.emit_signal("talkTo",talk_to)
