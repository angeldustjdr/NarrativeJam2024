extends Area2D

@export var type : GameState.thoughts
@export var friction : float = 2.0

func _on_body_entered(body):
	if body == %player : 
		Radio.emit_signal("bodyEnteredDepressionZone",body,type,friction)
		match type :
			GameState.thoughts.DEPRIME : Radio.emit_signal("showAlertMessage","Entering Depression zone")
			GameState.thoughts.PEUR : Radio.emit_signal("showAlertMessage","Entering Insecurity zone")
			GameState.thoughts.COLERE : Radio.emit_signal("showAlertMessage","Entering Anger zone")
			_ : push_error("Error in GameState.thoughts emun")


func _on_body_exited(body):
	if body == %player : 
		Radio.emit_signal("bodyExitedDepressionZone",body,type,friction)
