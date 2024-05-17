extends Control

@onready var focus = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	$%barre.pivot_offset = 0.5 * $%barre.size
	match GameState.get_main_title_state():
		GameState.CORPORATE:
			$%pirate.visible = false
			$Ethersea_text_corpo.visible = true
			$Ethersea_text_pirate.visible = false
			MusicManager.playMusicNamed("title_corpo",SceneTransitionLayer.get_duration("fade_in"))
		GameState.PIRATE:
			$%pirate.visible = true
			$Ethersea_text_corpo.visible = false
			$Ethersea_text_pirate.visible = true
			MusicManager.playMusicNamed("title_pirate",SceneTransitionLayer.get_duration("fade_in"))
		_:
			push_error("unexpected behavior")
	SceneTransitionLayer.reveal_scene()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	match focus:
		0:
			$AnimationPlayer.play("Play")
		1:
			$AnimationPlayer.play("Achievements")
		2:
			$AnimationPlayer.play("Credits")


func _on_play_mouse_entered():
	focus = 0
	


func _on_achievements_mouse_entered():
	focus = 1
	


func _on_credits_mouse_entered():
	focus = 2
	


func _on_play_mouse_exited():
	resetFocus()


func _on_achievements_mouse_exited():
	resetFocus()


func _on_credits_mouse_exited():
	resetFocus()

func resetFocus():
	focus = -1
	$AnimationPlayer.stop()


func _on_play_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			SceneTransitionLayer.transition_to_file_scene("res://Hub/hub.tscn")
			MusicManager.stopCurrent(SceneTransitionLayer.get_duration("fade_out"))


func _on_achievements_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			$AchivementsPanel.visible = true
			$AchivementsPanel.updatePanel()


func _on_credits_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			SceneTransitionLayer.transition_to_file_scene("res://credits.tscn")


func _on_achivements_panel_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			$AchivementsPanel.visible = false
