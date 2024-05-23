extends Node2D

@onready var unlock = preload("res://achivement_unlocked.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Achievements.connect("unlock",showUnlock)
	MusicManager.playMusicNamed("motivational",SceneTransitionLayer.get_duration("fade_in"))
	SceneTransitionLayer.reveal_scene()
	self._launch_speech()

func _launch_speech():
	var added_corruption = GameState._get_sum_missions_corrupted() - GameState.current_corruption_level
	match GameState.ending_speech:
		GameState.DENIAL_ENDING:
			if added_corruption == 0:
				GameState.start_time_line("tl_06hub_meeting_denial")
			else:
				GameState.start_time_line("tl_06hub_meeting_denial_influenced4")
			await(Dialogic.timeline_ended)
			self._change_scene_to_credits()
		GameState.EMPLOYEE_OF_THE_MONTH_ENDING:
			GameState.start_time_line("tl_06hub_meeting_best")
			await(Dialogic.timeline_ended)
			self._change_scene_to_credits()
		GameState.TRY_NEXT_MONTH_ENDING:
			GameState.start_time_line("tl_06hub_meeting_employee_influence4")
			await(Dialogic.timeline_ended)
			self._change_scene_to_credits()
		GameState.FIRED_ENDING:
			if added_corruption == 0:
				GameState.start_time_line("tl_06hub_meeting_fired")
			else:
				GameState.start_time_line("tl_06hub_meeting_fired_influenced4")
			await(Dialogic.timeline_ended)
			self._change_scene_to_credits()
		_:
			if Dialogic.current_timeline == null:
				Dialogic.start("tl_introcaptain_speech")
				Dialogic.timeline_ended.connect(self._change_scene_to_hub)

func _change_scene_to_hub():
	GameState.coming_from = GameState.NO_WHERE
	MusicManager.stopCurrent(SceneTransitionLayer.get_duration("fade_out"))
	SceneTransitionLayer.transition_to_file_scene("res://Hub/hub.tscn")
	
func _change_scene_to_main():
	MusicManager.stopCurrent(SceneTransitionLayer.get_duration("fade_out"))
	SceneTransitionLayer.transition_to_file_scene("res://main.tscn")
	
func _change_scene_to_credits():
	MusicManager.stopCurrent(SceneTransitionLayer.get_duration("fade_out"))
	SceneTransitionLayer.transition_to_file_scene("res://credits.tscn")

func showUnlock(message):
	var u = unlock.instantiate()
	u.text = "Achivement unlocked : " + message
	u.position = Vector2(64,1020-u.size.y)
	add_child(u)
