extends Node2D

@onready var hubscene = preload("res://Hub/hub.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	MusicManager.playMusicNamed("motivational",SceneTransitionLayer.get_duration("fade_in"))
	SceneTransitionLayer.reveal_scene()
	if Dialogic.current_timeline == null:
		Dialogic.start("tl_introcaptain_speech")
		Dialogic.timeline_ended.connect(self._change_scene)
		
func _change_scene():
	GameState.coming_from = GameState.NO_WHERE
	MusicManager.stopCurrent(SceneTransitionLayer.get_duration("fade_out"))
	SceneTransitionLayer.transition_to_packed_scene(hubscene)
