extends Node2D

@onready var open_world_packed_scene = preload("res://OpenWorld/open_world.tscn")

func _ready():
	GameState.check_mission_status()
	$CanvasLayer/UI/CenterContainer/MarginContainer/VBoxContainer/ElectricalZone/ColorRect.gui_input.connect(self._on_mission_pressed)
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

func _on_mission_pressed(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			GameState.start_current_mission()
			$scene_transition.transition_to_packed_scene(open_world_packed_scene)
