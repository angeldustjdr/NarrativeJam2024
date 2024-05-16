extends Node2D

@onready var unlock = preload("res://achivement_unlocked.tscn")

func _ready():
	MusicManager.playMusicNamed(self.name,$scene_transition.get_duration())
	GameState.check_mission_status()
	Radio.connect("clickObject",clickObject)
	Achievements.connect("unlock",showUnlock)
	Dialogic.timeline_ended.connect(_on_timeline_ended)

func clickObject(which):
	match which:
		"Organigram" : 
			%TalkToMenu.visible = false
			%ArmadaOrga.visible = true
			setClickableProcess()
		"Door" :
			%TalkToMenu.visible = false
			GameState.start_current_mission()
			MusicManager.stopCurrent($scene_transition.get_duration())
			$scene_transition.transition_to_packed_scene(GameState.openworld_packed_scene)
		"Employee" : 
			%TalkToMenu.visible = false
			%EmployeeMonth.visible = true
			setClickableProcess()
		"Coffee":
			%TalkToMenu.visible = false
			%TalkToMenu.display()
			setClickableProcess()
		"Achivement" :
			%TalkToMenu.visible = false
			%AchivementsPanel.updatePanel()
			%AchivementsPanel.visible = true
			setClickableProcess()
		_ : 
			push_warning("clickable not recognized")

func clear(exclude):
	for elem in $CanvasLayer/Control.get_children() : 
		if elem != exclude : elem.visible = false

func _on_panel_gui_input(event):
	if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				for elem in $CanvasLayer.get_children() : 
					elem.visible = false
				for clickable in $clickables.get_children():
					clickable.set_process(true)

func setClickableProcess():
	for clickable in $clickables.get_children(): clickable.set_process(false)

func showUnlock(message):
	var u = unlock.instantiate()
	u.text = "Achivement unlocked : " + message
	u.position = Vector2(64,1020-u.size.y)
	add_child(u)

func _on_timeline_ended():
	if GameState.coffeeCredit > 0 :
		GameState.nbCoffee += 1
		GameState.coffeeCredit = max(0,GameState.coffeeCredit-1)
		Achievements.checkCoffee(GameState.nbCoffee)
		$clickables/CoffeeMachine/CoffeeCredits.updateCoffe()
