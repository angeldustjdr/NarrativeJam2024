extends Node2D

@onready var unlock = preload("res://achivement_unlocked.tscn")

func _ready():
	GameState.stop_ether_timer()
	MusicManager.playMusicNamed(self.name,SceneTransitionLayer.get_duration("fade_in"))
	GameState.check_mission_status()
	Radio.connect("clickObject",clickObject)
	Achievements.connect("unlock",showUnlock)
	%TalkToMenu.coffee_credit_update.connect(self._on_coffee_credit_update)
	SceneTransitionLayer.reveal_scene()
	##### achievement
	GameState.nbRetourHub += 1
	if GameState.get_ether_timer_timeleft() > 0 :
		Achievements.genericCheck("Safe return")
	else :
		if GameState.nbRetourHub > 0 : Achievements.genericCheck("Better late than sorry")

func clickObject(which):
	match which:
		"Organigram" : 
			%TalkToMenu.visible = false
			%ArmadaOrga.visible = true
			setClickableProcess(PROCESS_MODE_DISABLED)
		"Door" :
			if Dialogic.current_timeline == null and GameState.coffeeCredit>0:
				Dialogic.start("res://Dialogue/timelines/tl_confirm_exit.dtl")
				Dialogic.timeline_ended.connect(self._go_in_mission)
		"Employee" : 
			%TalkToMenu.visible = false
			%EmployeeMonth.visible = true
			setClickableProcess(PROCESS_MODE_DISABLED)
		"Coffee":
			%TalkToMenu.visible = false
			%TalkToMenu.display()
			setClickableProcess(PROCESS_MODE_DISABLED)
		"Achivement" :
			%TalkToMenu.visible = false
			%AchivementsPanel.updatePanel()
			%AchivementsPanel.visible = true
			setClickableProcess(PROCESS_MODE_DISABLED)
		_ : 
			push_warning("clickable not recognized")

func _go_in_mission():
	Dialogic.timeline_ended.disconnect(self._go_in_mission)
	if Dialogic.VAR.confirm_exit:
		%TalkToMenu.visible = false
		GameState.start_current_mission()
		MusicManager.stopCurrent(SceneTransitionLayer.get_duration("fade_out"))
		SceneTransitionLayer.transition_to_packed_scene(GameState.openworld_packed_scene)

func clear(exclude):
	for elem in $CanvasLayer/Control.get_children() : 
		if elem != exclude : elem.visible = false

func _on_panel_gui_input(event):
	if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				closePanels()

func setClickableProcess(p_mode):
	for clickable in $clickables.get_children(): clickable.process_mode = p_mode

func showUnlock(message):
	var u = unlock.instantiate()
	u.text = "Achivement unlocked : " + message
	u.position = Vector2(64,1020-u.size.y)
	add_child(u)

func _on_coffee_credit_update(coffee_credit_descrease):
	setClickableProcess(PROCESS_MODE_ALWAYS)
	if coffee_credit_descrease:
		$clickables/CoffeeMachine/CoffeeCredits.updateCoffe()


func _on_achivements_panel_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			closePanels()

func closePanels():
	for elem in $CanvasLayer.get_children() : 
		elem.visible = false
	for clickable in $clickables.get_children():
		clickable.process_mode = PROCESS_MODE_ALWAYS
