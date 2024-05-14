extends Node2D

func _ready():
	GameState.check_mission_status()
	Radio.connect("clickObject",clickObject)

func clickObject(which):
	$CanvasLayer.visible = true
	match which:
		"Organigram" : 
			%ArmadaOrga.visible = true
			for clickable in $clickables.get_children():
				clickable.set_process(false)
		"Door" :
			$scene_transition.transition_to_packed_scene(GameState.openworld_packed_scene)
		_ : 
			push_warning("clickable not recognized")

func _on_armada_pressed():
	if Dialogic.current_timeline == null: 
		clear(%ArmadaOrga)
		%ArmadaOrga.visible = !%ArmadaOrga.visible

func _on_career_pressed():
	if Dialogic.current_timeline == null: 
		clear(%CareerInfo)
		%CareerInfo.visible = !%CareerInfo.visible

func _on_ach_pressed():
	if Dialogic.current_timeline == null: 
		clear(%Achievements)
		%Achievements.visible = !%Achievements.visible

func clear(exclude):
	for elem in $CanvasLayer/Control.get_children() : 
		if elem != exclude : elem.visible = false

func _on_close_button_pressed():
	for elem in $CanvasLayer.get_children() : 
		elem.visible = false
	for clickable in $clickables.get_children():
		clickable.set_process(true)
