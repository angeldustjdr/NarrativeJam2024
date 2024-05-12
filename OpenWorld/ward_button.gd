extends Button

func setText(n):
	text = "Ward #"+str(n)

func _on_pressed():
	disabled = true
	Radio.emit_signal("poserWard")
	
