extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	if GameState.is_bernard_calling():
		if GameState.revolutionStep == 1:
			$BernardCall.set_deferred("monitoring", false)
			$MissionOffPath.set_deferred("monitoring",true)
		elif GameState.revolutionStep == 0:
			$BernardCall.set_deferred("monitoring", true)
			$MissionOffPath.set_deferred("monitoring",true)
		else:
			$MissionOffPath.set_deferred("monitoring",false)
			$BernardCall.set_deferred("monitoring", false)
	else :
		$BernardCall.set_deferred("monitoring", false)
		$MissionOffPath.set_deferred("monitoring",false)

func _on_bernard_call_body_entered(body):
	if body==%player :
		if GameState.is_bernard_calling():
			%player.movable = false
			get_parent().showIntermediateDialog("tl_05mission5_anonymous") # schlag
			$RevolutionObjective1.visible = true
			%player.revolutionObjective = $RevolutionObjective1
			GameState.advanceRevolution()
			$BernardCall.set_deferred("monitoring",false)

func _on_mission_off_path_body_entered(body):
	if body==%player :
		if GameState.is_bernard_calling():
			%player.movable = false
			get_parent().showIntermediateDialog("tl_05mission5_offpath") # schlag
			$MissionOffPath.set_deferred("monitoring",false)
