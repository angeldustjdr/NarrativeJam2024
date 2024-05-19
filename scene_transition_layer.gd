extends CanvasLayer

signal fade_in_finished

# Called when the node enters the scene tree for the first time.
func _ready():
	$scene_transition.fade_in_finished.connect(self._on_fade_in_finished)

func get_duration(anim_name):
	return $scene_transition.get_duration(anim_name)

func _on_fade_in_finished():
	fade_in_finished.emit()
	Radio.click_enabled = true

func reveal_scene():
	$scene_transition.reveal_scene()

func transition_to_packed_scene(next_packed_scene):
	Radio.click_enabled = false
	$scene_transition.transition_to_packed_scene(next_packed_scene)
	
func transition_to_file_scene(next_packed_scene):
	Radio.click_enabled = false
	$scene_transition.transition_to_file_scene(next_packed_scene)
	
func quit_game():
	MusicManager.stopCurrent(self.get_duration("fade_out"))
	$scene_transition.quit_game()
