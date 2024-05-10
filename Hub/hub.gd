extends Node2D

func _ready():
	pass

func _on_clickable_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if Dialogic.current_timeline == null:
				Dialogic.start('Test_timeline')
