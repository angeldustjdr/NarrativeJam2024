extends TextureRect

func _ready():
	$ReferenceRect.mouse_entered.connect(self._on_area_2d_mouse_entered)
	$ReferenceRect.mouse_exited.connect(self._on_area_2d_mouse_exited)

func _on_area_2d_mouse_entered():
	if GameState._title_screen_state == GameState.CORPORATE:
		SoundManager.playSoundNamed("lock")
		$AnimationPlayer.play("lock")


func _on_area_2d_mouse_exited():
	if GameState._title_screen_state == GameState.CORPORATE:
		SoundManager.playSoundNamed("unlock")
		$AnimationPlayer.play("unlock")
