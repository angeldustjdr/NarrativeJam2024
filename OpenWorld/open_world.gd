extends Node2D

var nb_available_wards = 3
var wardbutton = preload("res://OpenWorld/ward_button.tscn")
var ward = preload("res://OpenWorld/ward.tscn")

var ilot_scenes_path = ["res://visual_novel/ilot_1.tscn",
						"res://visual_novel/ilot_2.tscn",
						"res://visual_novel/ilot_3.tscn",
						"res://visual_novel/ilot_4.tscn",
						"res://visual_novel/ilot_5.tscn",
						"res://Hub/hub.tscn"]

@onready var objectiveArray = [$Objective,$Objective2,$Objective3,$Objective4,$Objective5,$HUB]
@onready var iObjective = GameState.get_current_objective_idx()

@export var _music_name : String

func _ready():
	MusicManager.playMusicNamed(self._music_name,$scene_transition.get_duration())
	# Updating objective scene ##########################
	for i in range(0,len(self.objectiveArray)):
		objectiveArray[i].set_next_scene(ilot_scenes_path[i])
		objectiveArray[i].scene_need_changing.connect(self._scene_change)
	#####################################################
	Radio.connect("poserWard",poserWard)
	Radio.connect("setObjective",setObjective)
	#####################################################
	for i in range(nb_available_wards) : 
		var w = wardbutton.instantiate()
		w.setText(i+1)
		%VBoxContainer_Ward.add_child(w)
	setObjective()
	$player.player_connect()

func _scene_change(scene_name):
	MusicManager.stopCurrent($scene_transition.get_duration())
	$scene_transition.transition_to_file_scene(scene_name)

func poserWard():
	var w = ward.instantiate()
	w.global_position = $player.global_position
	$Ward.add_child(w)

func setObjective():
	self.iObjective = GameState.get_current_objective_idx()
	$player.objective = objectiveArray[self.iObjective]

func _process(_delta):
	# Update player position in GameState so that player appear in the good position after ilot
	GameState.player_position = $player.position
