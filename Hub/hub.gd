extends Node2D

@onready var unlock = preload("res://achivement_unlocked.tscn")

func _ready():
	##### achievement
	Achievements.connect("unlock",showUnlock)
	if GameState.coming_from != GameState.NO_WHERE: # si on ne vient pas de load
		GameState.nbRetourHub += 1
	#if GameState.nbRetourHub>0 : Achievements.genericCheck("True pilot")
	if GameState.get_ether_timer_timeleft() > 0 :
		Achievements.genericCheck("Safe return")
	if GameState.nbRetourHub > 0 : 
		Achievements.genericCheck("Better late than sorry")
	GameState.stop_ether_timer()
	MusicManager.playMusicNamed(self.name,SceneTransitionLayer.get_duration("fade_in"))
	GameState.check_mission_status()
	GameState.update_dialogs()
	Radio.connect("clickObject",clickObject)
	%TalkToMenu.coffee_credit_update.connect(self._on_coffee_credit_update)
	GameState.save_game("res://dev_save.save")
	SceneTransitionLayer.reveal_scene()

func clickObject(which):
	match which:
		"Organigram" : 
			%TalkToMenu.visible = false
			%ArmadaOrga.visible = true
			setClickableProcess(PROCESS_MODE_DISABLED)
		"Door" :
			GameState.start_time_line("res://Dialogue/timelines/tl_confirm_exit.dtl")
			Dialogic.timeline_ended.connect(self._go_in_mission)
		"Employee" : 
			%TalkToMenu.visible = false
			%EmployeeMonth.visible = true
			setClickableProcess(PROCESS_MODE_DISABLED)
		"Coffee":
			Dialogic.timeline_ended.connect(self._on_coffe_machine_started)
			GameState.start_time_line("tl_take_coffee")
			#%TalkToMenu.visible = false
			#%TalkToMenu.display()
			setClickableProcess(PROCESS_MODE_DISABLED)
		"Achivement" :
			%TalkToMenu.visible = false
			%AchivementsPanel.updatePanel()
			%AchivementsPanel.visible = true
			setClickableProcess(PROCESS_MODE_DISABLED)
		_ : 
			push_warning("clickable not recognized")

func _on_coffe_machine_started(): 
	await get_tree().create_timer(0.1).timeout #FUCKING DIALOGIC : my guess : si t'as pas attendu suffisamment y a des trucs qui sont pas decharges ça fout la merde.
	# MAIS CURRENT_TIMELINE est quand même NULL haha!
	Dialogic.timeline_ended.disconnect(self._on_coffe_machine_started)
	var character =  Dialogic.VAR.character_choice
	match character:
		GameState.NO_ONE:
			%TalkToMenu._on_leave_pressed()
		_:
			%TalkToMenu.talk_to_character(character)
	setClickableProcess(PROCESS_MODE_ALWAYS)

func _go_in_mission():
	Dialogic.timeline_ended.disconnect(self._go_in_mission)
	if Dialogic.VAR.confirm_exit:
		if not GameState.get_current_mission_idx() == GameState.HUB_ENDING:
			if GameState.get_current_mission_idx() == 0: # si on est a la mission 1 c'est le tuto
				# C'EST TRES LE TUTO
				await get_tree().create_timer(0.1).timeout 
				GameState.start_time_line("tl_hub01_exitoption")
				await(Dialogic.timeline_ended)
			%TalkToMenu.visible = false
			GameState.start_current_mission()
			MusicManager.stopCurrent(SceneTransitionLayer.get_duration("fade_out"))
			GameState.coming_from = GameState.HUB
			SceneTransitionLayer.transition_to_packed_scene(GameState.openworld_packed_scene)
		else:
			GameState.check_and_launch_corpo_ending()

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
