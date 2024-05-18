extends Node

signal poserWard
signal showAlertMessage
func showAlertFromDialogic(what):
	emit_signal("showAlertMessage",what)

signal interaction

signal bodyEnteredObjective
signal bodyExitedObjective
#signal setObjective # Not needed because objective change only when going back to openworld after ilot or hub.

signal bodyEnteredAccelerationZone
signal bodyExitedAccelerationZone
signal bodyEnteredDepressionZone
signal bodyExitedDepressionZone

signal clickObject

########### ACHIEVEMENTS
signal coffeeMade

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			SoundManager.playSoundNamed("confirm")
