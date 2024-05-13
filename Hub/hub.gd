extends Node2D

func _ready():
	Radio.connect("talkTo",talkTo)

func talkTo(_who):
	if Dialogic.current_timeline == null:
		Dialogic.start('Test_timeline') # A modifier


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


