extends Node2D

var nb_available_wards = 3
var wardbutton = preload("res://OpenWorld/ward_button.tscn")
var ward = preload("res://OpenWorld/ward.tscn")

@onready var unlock = preload("res://achivement_unlocked.tscn")

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
	if not GameState.coming_from == GameState.NO_WHERE:
		GameState.update_ether_timer()
		GameState.pause_ether_timer()
	self._set_intemperie()
	# Updating objective scene ##########################
	self.setObjective()
	self._init_objectives()
	#####################################################
	Radio.connect("poserWard",poserWard)
	for pos in GameState.wardPlacements:
		var w = ward.instantiate()
		w.global_position = pos
		$Ward/Custom.add_child(w)
	#Radio.connect("setObjective",setObjective) # Not needed because objective change only when going back to openworld after ilot or hub.
	Achievements.connect("unlock",showUnlock)
	Radio.connect("sendThoughts",showThoughts)
	#####################################################
	# check pour les zones d'acceleration et la révélation de la map
	self._check_map()
	#####################################################
	for i in range(nb_available_wards) : 
		var w = wardbutton.instantiate()
		w.setText(i+1)
		%VBoxContainer_Ward.add_child(w)
	# WTF? 
	$player.player_connect()

	%MissionLabel.text = GameState.get_current_mission()
	MusicManager.playMusicNamed(self._music_name,SceneTransitionLayer.get_duration("fade_in"))
	SceneTransitionLayer.reveal_scene()
	if not GameState._debug : await(SceneTransitionLayer.fade_in_finished)
	var brief = GameState.start_briefing_dialog()
	if brief:
		GameState.pause_ether_timer()
		await(Dialogic.timeline_ended)
		GameState.unpause_ether_timer()
		$player.movable = true
	else :
		if GameState.need_scolding():
			showIntermediateDialog(GameState.get_scolding_dialog())
		else:
			if not Dialogic.current_timeline == null:
				await(Dialogic.timeline_ended)
			GameState.unpause_ether_timer()
			$player.movable = true

func _check_map():
	# check pour les zones d'acceleration et la révélation de la map
	if GameState.mission_states["mission_1"]["finished"]:
		$AccelerationZones/Acc2.visible = true
		$AccelerationZones/Acc2.monitoring = true
		$Ward/Mission1.visible = true
	if GameState.mission_states["mission_2"]["finished"]:
		$Ward/Mission2.visible = true
		$"Terrain/Logo-vect-v3-pirate".visible = false
	if GameState.mission_states["mission_3"]["finished"]:
		$AccelerationZones/Acc3.visible = true
		$AccelerationZones/Acc3.monitoring = true
		$DepressionZones/Depression1.visible = false
		$DepressionZones/Depression1.monitoring = false
		$Ward/Mission3.visible = true
	if GameState.mission_states["mission_4"]["finished"]:
		$AccelerationZones/Acc4.visible = true
		$AccelerationZones/Acc4.monitoring = true
		$DepressionZones/Depression2.visible = false
		$DepressionZones/Depression2.monitoring = false
		$Ward/Mission4.visible = true
	if GameState.mission_states["mission_5"]["finished"]:
		$Ward/Mission5.visible = true

func _disconnect_objective():
	for objective in objectiveArray:
		if objective.scene_need_changing.is_connected(self._scene_change):
			objective.scene_need_changing.disconnect(self._scene_change)
	
func _init_objectives():
	var i_mission : int = GameState.get_current_mission_idx()
	if self.iObjective == GameState.HUB: 
		# Si l'objectif est le HUB alors on l'active
		objectiveArray[GameState.HUB].set_process_mode(PROCESS_MODE_PAUSABLE)
		objectiveArray[GameState.HUB].visible = true
		objectiveArray[GameState.HUB].set_next_scene(ilot_scenes_path[GameState.HUB])
		objectiveArray[GameState.HUB].scene_need_changing.connect(self._scene_change)
	else:
		# Sinon 
		objectiveArray[GameState.HUB].process_mode = PROCESS_MODE_DISABLED
		objectiveArray[GameState.HUB].visible = false
	for i in range(0,i_mission+1): 
	# Activation of ilots until current objective
		objectiveArray[i].process_mode = PROCESS_MODE_PAUSABLE
		objectiveArray[i].visible = true
		objectiveArray[i].set_next_scene(ilot_scenes_path[i])
		objectiveArray[i].scene_need_changing.connect(self._scene_change)
	for i in range(i_mission+1,GameState.get_number_of_mission()): 
	# Deactivation of upcoming objectives
		objectiveArray[i].process_mode = PROCESS_MODE_DISABLED
		objectiveArray[i].visible = false

func _set_intemperie():
	var intemperie_level = GameState.check_intemperie()
	$intemperie_texture.set_intemperie(intemperie_level)

func _scene_change(scene_name):
	GameState.pause_ether_timer()
	MusicManager.stopCurrent(SceneTransitionLayer.get_duration("fade_out"))
	SceneTransitionLayer.transition_to_file_scene(scene_name)

func poserWard():
	GameState.nbWard += 1
	Achievements.checkWard()
	var w = ward.instantiate()
	w.setPortable()
	w.global_position = $player.global_position
	GameState.wardPlacements.append(w.global_position)
	$Ward.add_child(w)

func setObjective():
	self.iObjective = GameState.get_current_objective_idx()
	$player.objective = objectiveArray[self.iObjective]

func _process(_delta):
	# Update player position in GameState so that player appear in the good position after ilot
	GameState.player_position = $player.position

func showUnlock(message):
	instanciateMessage(true,message,Vector2(1920/2,1080/2),true)

func showThoughts(message):
	var where = Vector2(randi_range(120,1920-320),randi_range(220,1080-220))
	instanciateMessage(false,message,where,false)

func instanciateMessage(isAchivement,message,where,sound):
	var u = unlock.instantiate()
	if isAchivement : u.text = "Achivement unlocked : " 
	u.text += message
	u.position = where
	u.withSound = sound
	$CanvasLayer/TextControl.add_child(u)

func _input(event):
	if event is InputEventKey:
		var dbg = false
		if event.keycode == KEY_V and event.pressed:
			# validate mission in time
			dbg = GameState.validate_current_mission_debug(true)
		elif event.keycode == KEY_B and event.pressed:
			#validate mission but not in_time
			dbg = GameState.validate_current_mission_debug(false)
		elif event.keycode == KEY_N and event.pressed:
			var terr = $Terrain/StaticBody2D
			if len(terr.get_collision_exceptions()) > 0:
				terr.remove_collision_exception_with($player)
			else:
				terr.add_collision_exception_with($player)
		if dbg:
			self._disconnect_objective()
			GameState.update_ether_timer()
			self.setObjective()
			self._init_objectives()
			self._set_intemperie()
			self._check_map()

func showIntermediateDialog(what):
	GameState.pause_ether_timer()
	GameState.start_time_line(what)
	await(Dialogic.timeline_ended)
	GameState.unpause_ether_timer()
	$player.movable = true
