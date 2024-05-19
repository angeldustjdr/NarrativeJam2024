extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	if GameState.is_bernard_calling():
		$BernardCall.set_deferred("monitoring", true)
		$MissionOffPath.set_deferred("monitoring",true)
	else :
		$BernardCall.set_deferred("monitoring", false)
		$MissionOffPath.set_deferred("monitoring",false)


func _on_bernard_call_body_entered(body):
	if body==%player :
		if GameState.is_bernard_calling():
			get_parent().showIntermediateDialog("tl_05mission5_anonymous") # schlag
			$RevolutionObjective1.visible = true
			%player.revolutionObjective = $RevolutionObjective1
			GameState.advanceRevolution()
			$BernardCall.set_deferred("monitoring",false)


func _on_mission_off_path_body_entered(body):
	if body==%player :
		if GameState.is_bernard_calling():
			get_parent().showIntermediateDialog("tl_05mission5_offpath") # schlag
			$MissionOffPath.set_deferred("monitoring",false)
