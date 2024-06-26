extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_process_mode(Node.PROCESS_MODE_WHEN_PAUSED)
	if FileAccess.file_exists("res://saves/slot_1.save"):
		%load_button.visible = true
	else:
		%load_button.visible = false
	%save_button.pressed.connect(self._on_save_button_pressed)
	%load_button.pressed.connect(self._on_load_button_pressed)
	%title_button.pressed.connect(self._on_title_button_pressed)
	%desktop_button.pressed.connect(self._on_desktop_button_pressed)
	%resume_button.pressed.connect(self._on_resume_button_pressed)

func _on_save_button_pressed():
	GameState.save_game_and_create_save_dir("slot_1.save")
	$AnimationPlayer.play("game_saved")
	
func _on_load_button_pressed():
	self.visible = false
	get_tree().paused = false
	GameState.load_game(GameState._save_dir + "slot_1.save")

func _on_title_button_pressed():
	self.visible = false
	get_tree().paused = false
	MusicManager.stopCurrent(SceneTransitionLayer.get_duration("fade_out"))
	SceneTransitionLayer.transition_to_file_scene("res://main.tscn")
	
func _on_desktop_button_pressed():
	self.visible = false
	get_tree().paused = false
	SceneTransitionLayer.quit_game()
	
func _on_resume_button_pressed():
	if GameState.is_pausable():
		if get_tree().paused:
			get_tree().paused = false
			PauseMenu.visible = false
		else:
			get_tree().paused = true
			PauseMenu.visible = true
