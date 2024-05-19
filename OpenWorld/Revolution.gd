extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	if GameState.ilot_states["ilot_5"]["revealed"] and GameState.mission_states["mission_5"]["started"] and !GameState.mission_states["mission_5"]["finished"]:
		$BernardCall.monitoring = true
		$MissionOffPath.monitoring = true
	else :
		$BernardCall.monitoring = false
		$MissionOffPath.monitoring = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_bernard_call_body_entered(body):
	if body==%player :
		get_parent().showIntermediateDialog("tl_05mission5_anonymous")
		$RevolutionObjective1.visible = true
		%player.revolutionObjective = $RevolutionObjective1
		GameState.advanceRevolution()


func _on_mission_off_path_body_entered(body):
	if body==%player :
		get_parent().showIntermediateDialog("tl_05mission5_offpath")
