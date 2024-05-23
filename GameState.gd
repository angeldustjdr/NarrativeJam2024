extends Node

enum {HUB = -1, ILOT = 5555, NO_WHERE = 7777} # HUB position in list

var _debug = false

enum {NONE, WEAK, STRONG} # level of intemperie

enum {CORPORATE, PIRATE} # TITLE

enum {CAPTAIN, SHIPGIRL, NAVIGATOR1, NAVIGATOR2} # Character

enum {NO_ONE=-9999}

enum {HUB_ENDING = 4444}

enum {INTRO = 3333}

enum {PIRATE_ENDING, DENIAL_ENDING, TRY_NEXT_MONTH_ENDING, EMPLOYEE_OF_THE_MONTH_ENDING, FIRED_ENDING}

enum thoughts {DEPRIME,COLERE,PEUR,RIEN=-1} # thoughts

var launch_tuto = false

@onready var openworld_packed_scene = preload("res://OpenWorld/open_world.tscn")
@onready var oscillo_packed_scene = preload("res://oscilloscope/oscilloscope_scene.tscn")

########### STATEMACHINE
signal save_finished
@onready var ilot_states = {"ilot_1":{"revealed":false,"beacon_destroyed":false,"visited_during_mission":[false,false,false,false,false]},
							"ilot_2":{"revealed":false,"beacon_destroyed":false,"visited_during_mission":[false,false,false,false,false]},
							"ilot_3":{"revealed":false,"beacon_destroyed":false,"visited_during_mission":[false,false,false,false,false]},
							"ilot_4":{"revealed":false,"beacon_destroyed":false,"visited_during_mission":[false,false,false,false,false]},
							"ilot_5":{"revealed":false,"beacon_destroyed":false,"visited_during_mission":[false,false,false,false,false]}}
@onready var mission_states = {"mission_1":{"started":false,"finished":false,"in_time":true,"debriefed":false,"scolded":false},
							   "mission_2":{"started":false,"finished":false,"in_time":true,"debriefed":false,"scolded":false},
							   "mission_3":{"started":false,"finished":false,"in_time":true,"debriefed":false,"scolded":false},
							   "mission_4":{"started":false,"finished":false,"in_time":true,"debriefed":false,"scolded":false},
							   "mission_5":{"started":false,"finished":false,"in_time":true,"debriefed":false,"scolded":false}}
@onready var mission_timer = {"mission_1": 120.,
							   "mission_2": 80.,
							   "mission_3": 60.,
							   "mission_4": 120.,
							   "mission_5": 240.}
@onready var mission_corrupted = {"mission_1": 0, #set in each corrupted dialog timeline !
							   "mission_2": 0,
							   "mission_3": 0,
							   "mission_4": 0,
							   "mission_5": 0}

@onready var nb_interaction_this_hub = { # nombre d'interactions avec chaque perso durant ce passage au HUB
	SHIPGIRL:0,
	NAVIGATOR1:0,
	NAVIGATOR2:0,
	CAPTAIN:0}

@onready var current_corruption_level : int = self._get_sum_missions_corrupted()

@onready var init_player_position = Vector2(838,4603) # initial coordinates of player
@onready var player_position = init_player_position
@onready var player_rotation = 0.0

var _title_screen_state : int

var _save_dir = "user://mindfarer/saves/"

########### ENDINGS

@onready var revolutionStep = 0
@onready var denialStep = 0
signal revolutionAdvanced
signal denialAdvanced
@onready var ending_speech : int # speech of the capitain for the intro

########### ETHER TIMER
var _ether_timer : Timer
var ether_timer_decrement : int = 15
var _ether_chrono : Chrono

########### ACHIEVEMENTS
@onready var nbCoffee = 0
@onready var coffeeCredit = 2
@onready var nbInteractions = {
	SHIPGIRL:0,
	NAVIGATOR1:0,
	NAVIGATOR2:0,
	CAPTAIN:0}
@onready var nbWard = 0
@onready var nbRetourHub = -1

@onready var wardPlacements = []

########### DIALOGS
@onready var _characters_available = {
	SHIPGIRL:true,
	NAVIGATOR1:true,
	NAVIGATOR2:false,
	CAPTAIN:true}

@onready var _current_timelines= {
	SHIPGIRL:"Test_timeline",
	NAVIGATOR1:"Test_timeline",
	NAVIGATOR2:"Test_timeline",
	CAPTAIN:"Test_timeline"}

var coming_from : int # hold previous scene for some reason

######## PV
var PV = 100
signal damageTaken

func takeDamage():
	PV = max(PV-10,0)
	emit_signal("damageTaken")
	if PV==0 : Achievements.genericCheck("Sabotage")

func resetPV():
	PV = 100.0
	emit_signal("damageTaken")
##########

################################################################################
#LOAD AND SAVE MOTHEFUCKERS ####################################################
################################################################################

func print_data():
	print(self.mission_states)
	print(self.ilot_states)
	print(self.mission_corrupted)
	print(self.current_corruption_level)
	print(self.nb_interaction_this_hub)
	print(self.revolutionStep)
	print(self.denialStep)
	print(self._ether_timer.is_stopped())
	print(self._ether_timer.wait_time)
	print(self._ether_timer.time_left)
	print(self._ether_timer.paused)
	print(self.player_position)
	print(self.PV)

func save_game_and_create_save_dir(slot_file_name):
	var dir = DirAccess.open("user://")
	if not dir.dir_exists(self._save_dir):
		dir.make_dir("mindfarer")
		dir = DirAccess.open("user://mindfarer/")
		dir.make_dir(self._save_dir)
	self.save_game(self._save_dir + slot_file_name)

func save_game(file_name):
	#print("SAVED DATA:")
	#self.print_data()
	var savefile = FileAccess.open(file_name, FileAccess.WRITE)
	savefile.store_var(self.mission_states)
	savefile.store_var(self.ilot_states)
	savefile.store_var(self.mission_corrupted)
	savefile.store_var(self.current_corruption_level)
	savefile.store_var(self.nb_interaction_this_hub)
	savefile.store_var(self.revolutionStep)
	savefile.store_var(self.denialStep)
	#ether_timer######################
	savefile.store_var(self._ether_timer.is_stopped())
	savefile.store_var(self._ether_timer.wait_time)
	savefile.store_var(self._ether_timer.time_left)
	savefile.store_var(self._ether_timer.paused)
	##################################
	savefile.store_var(self.player_position)
	savefile.store_var(self.player_rotation)
	savefile.store_var(self.PV)
	savefile.store_var(self._title_screen_state)
	savefile.store_var(get_tree().current_scene.scene_file_path)
	#print("SAVE_FINISHED")
	#self.save_finished.emit()
	
func load_game(file_name):
	if not FileAccess.file_exists(file_name):
		push_error("save file named : "+file_name+" not found")
	var savefile = FileAccess.open(file_name, FileAccess.READ)
	self.mission_states = savefile.get_var()
	self.ilot_states = savefile.get_var()
	self.mission_corrupted = savefile.get_var()
	self.current_corruption_level = savefile.get_var()
	self.nb_interaction_this_hub = savefile.get_var()
	self.revolutionStep = savefile.get_var()
	self.denialStep = savefile.get_var()
	#ether_timer######################
	var stopped_timer = savefile.get_var()
	var _wait_time_timer = savefile.get_var()
	var time_left_timer = savefile.get_var()
	var _timer_paused = savefile.get_var()
	self._init_ether_timer()
	if not stopped_timer:
		self._ether_timer.wait_time = time_left_timer
		self._ether_timer.start()
		self._ether_timer.paused = true
	##################################
	self.player_position = savefile.get_var()
	self.player_rotation = savefile.get_var()
	self.PV = savefile.get_var()
	self._title_screen_state = savefile.get_var()
	var file_scene_name = savefile.get_var()
	self.coming_from = NO_WHERE
	MusicManager.stopCurrent(SceneTransitionLayer.get_duration("fade_out"))
	SceneTransitionLayer.transition_to_file_scene(file_scene_name)

################################################################################
################################################################################
################################################################################

func _ready():
	self.set_process_mode(PROCESS_MODE_ALWAYS)
	self._init_ether_timer()

# Related to endings
func is_bernard_calling():
	var mission_idx = self.get_current_mission_idx() 
	var ilot_name = self.ilot_states.keys()[mission_idx]
	if mission_idx == 4 and self.ilot_states[ilot_name]["revealed"]: # MISSION 5
		if self._get_sum_missions_corrupted() > 0: # si on est retourne au moins si un ilot corrompu
			return true
		else:
			return false
	else:
		return false

func _get_sum_missions_corrupted():
	var sum = 0
	for mission in self.mission_corrupted.keys():
		sum += self.mission_corrupted[mission]
	return sum

# Proposition de fonctionnement #####
# revolutionStep == 0 and denialStep == 0 et retour au HUB : 
#	fin employe modele si ... (mission in_time / niveau de corruption?)
#	fin employe try next month si ... (mission in_time / niveau de corruption?)
# des qu'on a choisit l'option avec bernard : fin pirate
# revolutionStep > 0 and denialStep == 0 et retour au HUB : fin HUB vire
# denialStep == 1 a la fin : fin deni
# sinon : unexpected.
func advanceRevolution(): 
	revolutionStep+=1
	emit_signal("revolutionAdvanced")

func advanceDenial(): 
	denialStep+=1
	emit_signal("denialAdvanced")

# appele dans ilot_generic
func check_beacon_destruction():
	if self.get_nb_beacon_destroyed() == self.get_nb_ilot():
		return true

func check_corpo_ending():
	if(self.ilot_states["ilot_5"]["revealed"]):
		if self.denialStep == 1:
			self.ending_speech = FIRED_ENDING
			return FIRED_ENDING
		else:
			if self.employee_of_the_month():
				self.ending_speech = EMPLOYEE_OF_THE_MONTH_ENDING
				return EMPLOYEE_OF_THE_MONTH_ENDING
			else:
				self.ending_speech = TRY_NEXT_MONTH_ENDING
				return TRY_NEXT_MONTH_ENDING
	else:
		return INTRO

func check_and_launch_corpo_ending():
	self.launch_ending(check_corpo_ending())

func launch_ending(i_ending):
	self.ending_speech = i_ending
	var next_scene : String
	match i_ending:
		PIRATE_ENDING:
			self._title_screen_state = PIRATE
			Achievements.save_achievements()
			Achievements.genericCheck("Rage against the machine")
			#print("ENDING : PIRATE")
			next_scene = "res://credits.tscn"
		DENIAL_ENDING:
			Achievements.genericCheck("Cosmic denial")
			next_scene = "res://Hub/motivational_speech.tscn"
		TRY_NEXT_MONTH_ENDING:
			Achievements.genericCheck("Maybe next month")
			next_scene = "res://Hub/motivational_speech.tscn"
		EMPLOYEE_OF_THE_MONTH_ENDING:
			Achievements.genericCheck("Employee of the month")
			next_scene = "res://Hub/motivational_speech.tscn"
		FIRED_ENDING:
			Achievements.genericCheck("You're fired!")
			next_scene = "res://Hub/motivational_speech.tscn"
		_:
			push_error("ENDING : unexpected...")
	MusicManager.stopCurrent(SceneTransitionLayer.get_duration("fade_out"))
	SceneTransitionLayer.transition_to_file_scene(next_scene)

func employee_of_the_month(): # CONDITION for employee of the month
	#var added_corruption = self._get_sum_missions_corrupted() - self.current_corruption_level
	#return added_corruption == 0
	return self.get_nb_mission_in_time() > 4 # si le joueur a fait plus de trois missions dans les temps

func get_nb_mission_in_time():
	var c = 0
	for mission in self.mission_states.keys():
		if self.mission_states[mission]["in_time"]:
			c += 1
	return c

func get_nb_beacon_destroyed():
	var c = 0
	for ilot in self.ilot_states.keys():
		if self.ilot_states[ilot]["beacon_destroyed"]:
			c += 1
	return c
	
func get_nb_ilot():
	return len(self.ilot_states.keys())
	
func get_nb_mission():
	return len(self.mission_states.keys())

func is_destruction_launched():
	return (self.revolutionStep > 2 and self.denialStep == 0) # Si destruction des balises

func setMission_corrupted(which):
	mission_corrupted[which] += 1

func need_scolding():
	match self.get_current_mission_idx():
		3: #MISSION4
			return (GameState.mission_corrupted["mission_1"]>0 and 
					GameState.mission_corrupted["mission_2"]>0 and 
					GameState.mission_corrupted["mission_3"]>0)
			# le scolding ne se declenche que quand on a revisité au moins une fois tous les ilots predents.
		4: #MISSION5
			return (GameState.mission_corrupted["mission_1"]>0 and 
					GameState.mission_corrupted["mission_2"]>0 and 
					GameState.mission_corrupted["mission_3"]>0 and 
					GameState.mission_corrupted["mission_4"]>0)
			# le scolding ne se declenche que quand on a revisité au moins une fois tous les ilots predents.
		_: #AUTRE MISSION
			return false
			# pas de scolding dans les autres missions
		
func get_scolding_dialog():
	match self.get_current_mission_idx():
		3: # MISSION 4
			return "tl_04mission4_scold"
		4: # MISSION 5
			return "tl_05mission5_scold"
		_:
			push_error("unexpected behavior")

# Related to dialogs
func start_time_line(timeline_name,wait=false):
	if Dialogic.current_timeline == null:
		Dialogic.start(timeline_name).layer = 5
		if wait: # morche po :'(
			await(Dialogic.timeline_ended)

func update_dialogs():
	self.reset_this_hub_interactions()
	self.update_characters_availability()
	self._update_current_timelines()

func reset_this_hub_interactions():
	self.nb_interaction_this_hub = { # nombre d'interactions avec chaque perso durant ce passage au HUB
	SHIPGIRL:0,
	NAVIGATOR1:0,
	NAVIGATOR2:0,
	CAPTAIN:0}

func get_current_timeline(character):
	return self._current_timelines[character]

func start_briefing_dialog():
	if self.coming_from == HUB: # Si on sort du HUB on joue une timeline briefing, sinon non.
		resetPV()
		match self.get_current_mission_idx():
			0: #MISSION 1
				if self.launch_tuto:
					self.start_time_line("tl_hub01_simulation")
				else:
					self.start_time_line("tl_mission1_navigator1_objectif")
			1: #MISSION 2
				self.start_time_line("tl_02mission2_objectif")
			2: #MISSION 3
				self.start_time_line("tl_03mission3_objectif")
			3: #MISSION 4
				self.start_time_line("tl_04mission4_objectif")
			4: #MISSION 5
				self.start_time_line("tl_05mission5_objectif")
			_: 
				push_error("unexpected behavior, not a recognized mission name")
		return true
	elif self.coming_from == ILOT:
		var mission = self.get_current_mission()
		if not self.mission_states[mission]["debriefed"]:
			self.mission_states[mission]["debriefed"] = true
			if ilot_states["ilot_1"]["revealed"] and mission_states["mission_1"]["started"] and !mission_states["mission_1"]["finished"]:
				self.start_time_line("tl_mission1_navigator1_retour")
				return true
			elif ilot_states["ilot_2"]["revealed"] and mission_states["mission_2"]["started"] and !mission_states["mission_2"]["finished"]:
				self.start_time_line("tl_02mission2_return")
				return true
			elif ilot_states["ilot_3"]["revealed"] and mission_states["mission_3"]["started"] and !mission_states["mission_3"]["finished"]:
				self.start_time_line("tl_03mission3_return")
				return true
			elif ilot_states["ilot_4"]["revealed"] and mission_states["mission_4"]["started"] and !mission_states["mission_4"]["finished"]:
				self.start_time_line("tl_04mission4_return")
				return true
			elif ilot_states["ilot_5"]["revealed"] and mission_states["mission_5"]["started"] and !mission_states["mission_5"]["finished"]:
				self.start_time_line("tl_05mission5_return")
				return true
			else :
				self.mission_states[mission]["debriefed"] = false
				return false
		else:
			return false
	else:
		return false

func start_ilot_dialog_navigator(numero_ilot):
	match self.get_current_mission_idx():
		0: #MISSION 1
			if ilot_states["ilot_1"]["revealed"] == false and numero_ilot==1: self.start_time_line("tl_mission1_navigator1_arrival")
		1: #MISSION 2
			if ilot_states["ilot_2"]["revealed"] == false and numero_ilot==2 : self.start_time_line("tl_02mission2_arrival")
		2: #MISSION 3
			if ilot_states["ilot_3"]["revealed"] == false and numero_ilot==3 : self.start_time_line("tl_03mission3_arrival")
		3: #MISSION 4
			if ilot_states["ilot_4"]["revealed"] == false and numero_ilot==4 : self.start_time_line("tl_04mission4_arrival")
		4: #MISSION 5
			if ilot_states["ilot_5"]["revealed"] == false and numero_ilot==5 : self.start_time_line("tl_05mission5_arrival")
		_: 
			push_error("unexpected behavior, not a recognized mission name")

func _update_current_timelines():
	#HERE WE FUCKING GO
	var added_corruption = self._get_sum_missions_corrupted() - self.current_corruption_level
	if added_corruption < 0 :
		push_error("Unexpected behavior")
	match self.get_current_mission_idx():
		0: #MISSION 1
			self._current_timelines[GameState.SHIPGIRL] = "tl_hub01_shipgirl"
			self._current_timelines[GameState.NAVIGATOR1] = "tl_hub01_navigator1"
			self._current_timelines[GameState.NAVIGATOR2] = "Test_timeline"
			self._current_timelines[GameState.CAPTAIN] = "tl_hub01_captain"
			self.current_corruption_level = self._get_sum_missions_corrupted()
		1: #MISSION 2
			self._current_timelines[GameState.SHIPGIRL] = "tl_02hub_shipgirl_coffee"
			self._current_timelines[GameState.NAVIGATOR1] = "tl_02hub_navigator1_coffee"
			self._current_timelines[GameState.NAVIGATOR2] = "Test_timeline"
			self._current_timelines[GameState.CAPTAIN] = "tl_02hub_captain_coffee"
			self.current_corruption_level = self._get_sum_missions_corrupted()
		2: #MISSION 3
			if added_corruption > 0:
				self._current_timelines[GameState.SHIPGIRL] = "influenced1/tl_03hub_shipgirl3_coffee_influenced1"
				self._current_timelines[GameState.NAVIGATOR1] = "influenced1/tl_03hub_navigator3_coffee_influenced"
				self._current_timelines[GameState.NAVIGATOR2] = "Test_timeline"
				self._current_timelines[GameState.CAPTAIN] = "influenced1/tl_03hub_captain3_coffee_influenced1"
			else :
				self._current_timelines[GameState.SHIPGIRL] = "tl_03hub_shipgirl3_coffee"
				self._current_timelines[GameState.NAVIGATOR1] = "tl_03hub_navigator1_coffee"
				self._current_timelines[GameState.NAVIGATOR2] = "Test_timeline"
				self._current_timelines[GameState.CAPTAIN] = "tl_03hub_captain3_coffee"
			self.current_corruption_level = self._get_sum_missions_corrupted()
		3: #MISSION 4
			if added_corruption > 0:
				self._current_timelines[GameState.SHIPGIRL] = "influenced2/tl_04hub_shipgirl4_coffee_influenced2"
				self._current_timelines[GameState.NAVIGATOR1] = "influenced2/tl_04hub_navigator4_coffee_influenced2"
				self._current_timelines[GameState.NAVIGATOR2] = "Test_timeline"
				self._current_timelines[GameState.CAPTAIN] = "influenced2/tl_04hub_captain4_coffee_influenced2"
			else :
				self._current_timelines[GameState.SHIPGIRL] = "tl_04hub_shipgirl4_coffee"
				self._current_timelines[GameState.NAVIGATOR1] = "tl_04hub_navigator4_coffee"
				self._current_timelines[GameState.NAVIGATOR2] = "Test_timeline"
				self._current_timelines[GameState.CAPTAIN] = "tl_04hub_captain4_coffee"
			self.current_corruption_level = self._get_sum_missions_corrupted()
		4: #MISSION 5
			if added_corruption > 0:
				self._current_timelines[GameState.SHIPGIRL] = "tl_05hub_shipgirl5_coffee_influenced3"
				self._current_timelines[GameState.NAVIGATOR1] = "Test_timeline"
				self._current_timelines[GameState.NAVIGATOR2] = "tl_05hub_navigator5_coffee_influenced3"
				self._current_timelines[GameState.CAPTAIN] = "tl_05hub_captain5_coffee_influenced3"
			else :
				self._current_timelines[GameState.SHIPGIRL] = "tl_05hub_shipgirl5_coffee"
				self._current_timelines[GameState.NAVIGATOR1] = "Test_timeline"
				self._current_timelines[GameState.NAVIGATOR2] = "tl_05hub_navigator5_coffee"
				self._current_timelines[GameState.CAPTAIN] = "tl_05hub_captain5_coffee"
			self.current_corruption_level = self._get_sum_missions_corrupted()
		HUB_ENDING:
				var ending = self.check_corpo_ending() # en fonction des endings
				if ending == EMPLOYEE_OF_THE_MONTH_ENDING:
					if added_corruption == 0:
						self._current_timelines[GameState.SHIPGIRL] = "tl_06hub_shipgirl6_coffee_best"
						self._current_timelines[GameState.NAVIGATOR1] = "Test_timeline"
						self._current_timelines[GameState.NAVIGATOR2] = "tl_06hub_navigator6_coffee_best"
						self._current_timelines[GameState.CAPTAIN] = "tl_06hub_captain6_coffee_best"
					elif added_corruption > 0:
						self._current_timelines[GameState.SHIPGIRL] = "Test_timeline"
						self._current_timelines[GameState.NAVIGATOR1] = "Test_timeline"
						self._current_timelines[GameState.NAVIGATOR2] = "Test_timeline"
						self._current_timelines[GameState.CAPTAIN] = "Test_timeline"
				elif ending == DENIAL_ENDING:
					if added_corruption == 0:
						self._current_timelines[GameState.SHIPGIRL] = "tl_06hub_shipgirl6_coffee_denial"
						self._current_timelines[GameState.NAVIGATOR1] = "Test_timeline"
						self._current_timelines[GameState.NAVIGATOR2] = "tl_06hub_navigator6_coffee_denial"
						self._current_timelines[GameState.CAPTAIN] = "tl_06hub_captain6_coffee_denial"
					elif added_corruption > 0:
						self._current_timelines[GameState.SHIPGIRL] = "tl_06hub_shipgirl6_coffee_denial_influenced4"
						self._current_timelines[GameState.NAVIGATOR1] = "Test_timeline"
						self._current_timelines[GameState.NAVIGATOR2] = "tl_06hub_navigator6_coffee_denial_influenced4"
						self._current_timelines[GameState.CAPTAIN] = "tl_06hub_captain6_coffee_denial_influenced4"
				elif ending == FIRED_ENDING:
					if added_corruption == 0:
						self._current_timelines[GameState.SHIPGIRL] = "tl_06hub_shipgirl6_coffee_fired"
						self._current_timelines[GameState.NAVIGATOR1] = "Test_timeline"
						self._current_timelines[GameState.NAVIGATOR2] = "tl_06hub_navigator6_coffee_fired"
						self._current_timelines[GameState.CAPTAIN] = "tl_06hub_captain6_coffee_fired"
					elif added_corruption > 0:
						self._current_timelines[GameState.SHIPGIRL] = "tl_06hub_shipgirl6_coffee_fired_influenced4"
						self._current_timelines[GameState.NAVIGATOR1] = "Test_timeline"
						self._current_timelines[GameState.NAVIGATOR2] = "tl_06hub_navigator6_coffee_fired_influenced4"
						self._current_timelines[GameState.CAPTAIN] = "tl_06hub_captain6_coffee_fired_influenced4"
				elif ending == TRY_NEXT_MONTH_ENDING:
					if added_corruption == 0:
						self._current_timelines[GameState.SHIPGIRL] = "Test_timeline"
						self._current_timelines[GameState.NAVIGATOR1] = "Test_timeline"
						self._current_timelines[GameState.NAVIGATOR2] = "Test_timeline"
						self._current_timelines[GameState.CAPTAIN] = "Test_timeline"
					elif added_corruption > 0:
						self._current_timelines[GameState.SHIPGIRL] = "tl_06hub_shipgirl6_coffee_employee_influenced4"
						self._current_timelines[GameState.NAVIGATOR1] = "Test_timeline"
						self._current_timelines[GameState.NAVIGATOR2] = "tl_06hub_navigator6_coffee_employee_influenced4"
						self._current_timelines[GameState.CAPTAIN] = "tl_06hub_captain6_coffee_employee_influenced4"
				else:
					self._current_timelines[GameState.SHIPGIRL] = "Test_timeline"
					self._current_timelines[GameState.NAVIGATOR1] = "Test_timeline"
					self._current_timelines[GameState.NAVIGATOR2] = "Test_timeline"
					self._current_timelines[GameState.CAPTAIN] = "Test_timeline"
		_: 
			push_error("unexpected behavior, not a recognized mission name")

func update_characters_availability():
	# check availability at coffee machine
	match self.get_current_mission_idx():
		0: #MISSION 1
			self._characters_available = {
				SHIPGIRL:self.nb_interaction_this_hub[SHIPGIRL]==0,
				NAVIGATOR1:self.nb_interaction_this_hub[NAVIGATOR1]==0,
				NAVIGATOR2:false,
				CAPTAIN:self.nb_interaction_this_hub[CAPTAIN]==0}
		1: #MISSION 2
			self._characters_available = {
				SHIPGIRL:self.nb_interaction_this_hub[SHIPGIRL]==0,
				NAVIGATOR1:self.nb_interaction_this_hub[NAVIGATOR1]==0,
				NAVIGATOR2:false,
				CAPTAIN:self.nb_interaction_this_hub[CAPTAIN]==0}
		2: #MISSION 3
			self._characters_available = {
				SHIPGIRL:self.nb_interaction_this_hub[SHIPGIRL]==0,
				NAVIGATOR1:self.nb_interaction_this_hub[NAVIGATOR1]==0,
				NAVIGATOR2:false,
				CAPTAIN:self.nb_interaction_this_hub[CAPTAIN]==0}
		3: #MISSION 4
			self._characters_available = {
				SHIPGIRL:self.nb_interaction_this_hub[SHIPGIRL]==0,
				NAVIGATOR1:self.nb_interaction_this_hub[NAVIGATOR1]==0,
				NAVIGATOR2:false,
				CAPTAIN:self.nb_interaction_this_hub[CAPTAIN]==0}
		4: #MISSION 5
			self._characters_available = {
				SHIPGIRL:self.nb_interaction_this_hub[SHIPGIRL]==0,
				NAVIGATOR1:false,
				NAVIGATOR2:self.nb_interaction_this_hub[NAVIGATOR2]==0,
				CAPTAIN:self.nb_interaction_this_hub[CAPTAIN]==0}
		HUB_ENDING:
			self._characters_available = {
				SHIPGIRL:self.nb_interaction_this_hub[SHIPGIRL]==0,
				NAVIGATOR1:false,
				NAVIGATOR2:self.nb_interaction_this_hub[NAVIGATOR2]==0,
				CAPTAIN:self.nb_interaction_this_hub[CAPTAIN]==0}
		_: 
			push_error("unexpected behavior, not a recognized mission name")

func is_character_available(character):
	return self._characters_available[character]

func _play_dialog_return_to_hub():
	var mission_idx = self.get_current_mission_idx()
	var mission = self.mission_states.keys()[mission_idx]
	match mission_idx:
		0: #MISSION 1
			if self.mission_states[mission]["in_time"]:
				GameState.start_time_line("tl_02hub_captain_missiontimly")
			else:
				GameState.start_time_line("tl_02hub_captain_missionlate")
		1: #MISSION 2
			if self.mission_states[mission]["in_time"]:
				GameState.start_time_line("tl_03hub_captain_missiontimely")
			else:
				GameState.start_time_line("tl_03hub_captain_missionlate")
		2: #MISSION 3
			if self.mission_states[mission]["in_time"]:
				GameState.start_time_line("tl_04hub_captain_missiontimly")
			else:
				GameState.start_time_line("tl_04hub_captain_missionlate")
		3: #MISSION 4
			if self.mission_states[mission]["in_time"]:
				GameState.start_time_line("tl_05hub_captain_missiontimely")
			else:
				GameState.start_time_line("tl_05hub_captain_missionlate")
		4: #MISSION 5
			if self.mission_states[mission]["in_time"]:
				GameState.start_time_line("tl_06hub_captain_missiontimely")
			else:
				GameState.start_time_line("tl_06hub_captain_missionlate")
		_:
			push_error("unexpected_behavior")
	await(Dialogic.timeline_ended)

# Main title relatives
func get_main_title_state():
	return self._title_screen_state

func print_time_elapsed(time):
	if self._debug:
		var mission = self.get_current_mission()
		print(mission + " COMPLETED IN " +str(time))
		print(self.mission_corrupted)

# Ether timer relatives
func _init_ether_timer():
	self._ether_timer = Timer.new()
	self._ether_timer.one_shot = true
	self._ether_timer.timeout.connect(self._on_ether_timer_timeout)
	self.add_child(self._ether_timer)
	# CHRONO
	self._ether_chrono = Chrono.new()
	self.add_child(self._ether_chrono)
	

func update_ether_timer():
	# fonction appelee quand on arrive dans l'openworld
	if self._ether_timer.is_stopped(): # si le timer est stop la mission est soit fail, soit pas demarree
		var mission = self.get_current_mission()
		if self.mission_states[mission]["in_time"]:  # donc si elle est pas fail, ça veut dire qu'on sort du HUB et donc qu'on commence une nouvelle mission
			self._ether_timer.wait_time = GameState.mission_timer[GameState.get_current_mission()]
			self.start_ether_timer()
	elif self._ether_timer.paused:
		# le timer est paused quand on sort d'un ilot
		self._ether_timer.paused = false
		# chrono
		self._ether_chrono.unpause()
	else:
		if GameState._debug:
			var mission = self.get_current_mission()
			if self.mission_states[mission]["in_time"]:  # donc si elle est pas fail, ça veut dire qu'on sort du HUB et donc qu'on commence une nouvelle mission
				self.stop_ether_timer()
				self._ether_timer.wait_time = GameState.mission_timer[GameState.get_current_mission()]
				self.start_ether_timer()
		else:
			push_error("unexpected behavior")

func decrement_ether_timer():
	if self._ether_timer.time_left - self.ether_timer_decrement < 0. :
		self._ether_timer.stop()
		self._ether_timer.timeout.emit()
	else:
		if not self._ether_timer.is_stopped():
			var p = self._ether_timer.paused
			self._ether_timer.start(self._ether_timer.time_left - self.ether_timer_decrement)
			if p:
				self.pause_ether_timer()
	self._ether_chrono.increment(self.ether_timer_decrement)
	
func stop_ether_timer():
	if not self._ether_timer.is_stopped():
		self._ether_timer.stop()
	else:
		push_warning("trying to stop already stopped ether_timer")
	return self._ether_chrono.stop_and_get_current_time()

func start_ether_timer():
	if self._ether_timer.is_stopped():
		self._ether_timer.start()
		self._ether_chrono.start()
	else:
		push_warning("trying to play already playing ether_timer") 

func pause_ether_timer():
	if not self._ether_timer.is_stopped():
		if self._ether_timer.paused == false:
			self._ether_timer.paused = true
			self._ether_chrono.pause()

func unpause_ether_timer():
	if self._ether_timer.paused == true:
		self._ether_timer.paused = false
		self._ether_chrono.unpause()

func get_ether_timer_timeleft():
	return self._ether_timer.time_left
	
func _on_ether_timer_timeout():
	self.mission_states[GameState.get_current_mission()]["in_time"] = false

# Mission relatives
func get_number_of_mission():
	return len(self.mission_states.keys())

func get_current_mission_idx():
	var keep = true
	var mission_keys = self.mission_states.keys()
	var c = 0
	while keep == true:
		if c == self.get_nb_mission():
			return HUB_ENDING
		else:
			keep = self.mission_states[mission_keys[c]]["finished"]
			c += 1
	return c-1

func start_current_mission():
	self.mission_states[self.get_current_mission()]["started"] = true

func check_mission_status():
	# Checks the mission status once at HUB
	var mission_idx = get_current_mission_idx()
	var mission = self.mission_states.keys()[mission_idx]
	var ilot = self.ilot_states.keys()[mission_idx]
	if self.ilot_states[ilot]["revealed"]:
		self._play_dialog_return_to_hub()
		self.mission_states[mission]["finished"] = true
	self.check_intemperie()

func get_current_mission():
	if self.get_current_mission_idx() != HUB_ENDING:
		var mission_keys = self.mission_states.keys()
		return mission_keys[self.get_current_mission_idx()]
	else:
		return "ending"
	
func get_current_objective_idx():
	var i = get_current_mission_idx() # number of the mission
	var curr_ilot = self.ilot_states.keys()[i]
	if ilot_states[curr_ilot]["revealed"]: # if the ilot is already revealed
		return HUB # then we need to return to the HUB
	else:
		return i # else we need to go to ilot i

func get_current_window_ratio():
	var v_port_size = get_viewport().size
	return min(float(v_port_size[0])/ProjectSettings.get_setting("display/window/size/viewport_width"),
			   float(v_port_size[1])/ProjectSettings.get_setting("display/window/size/viewport_height"))
			
func check_intemperie():
	# Si la mission_3 est en cours
	if self.mission_states["mission_3"]["started"] and not self.mission_states["mission_3"]["finished"]:
		MusicManager.set_intemperie(WEAK)
		return WEAK
	# Si la mission_5 est en cours
	elif self.mission_states["mission_5"]["started"] and not self.mission_states["mission_5"]["finished"]:
		MusicManager.set_intemperie(STRONG)
		return STRONG
	else:
		MusicManager.set_intemperie(NONE)
		return NONE

# DEBUG

func validate_current_mission_debug(in_time):
	if self._debug:
		var i_mission = self.get_current_mission_idx()
		var mission_str = self.mission_states.keys()[i_mission]
		var ilot_str = self.ilot_states.keys()[i_mission]
		if i_mission != self.get_nb_mission()-1: # not last mission
			self.mission_states[mission_str]["finished"] = true
		self.mission_states[mission_str]["debriefed"] = true
		self.mission_states[mission_str]["in_time"] = in_time
		self.ilot_states[ilot_str]["revealed"] = true
		if i_mission != self.get_nb_mission()-1: # not last mission
			self.print_time_elapsed(self._ether_chrono.stop_and_get_current_time())
			self.start_current_mission()
		self.check_intemperie()
	return self._debug

# menu pause

func is_pausable():
	match get_tree().current_scene.scene_file_path:
		"res://main.tscn": #on peut pas poser l'ecran titre
			return false
		"res://logo.tscn": #ni le logo du studio
			return false
		"res://Hub/motivational_speech.tscn": #ni le motivational speech
			return false
		_:
			if not Dialogic.current_timeline == null: #on peut pas pauser pendant les dialogues
				return false
			else:
				return true
				

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_TAB and event.pressed:
			if self.is_pausable():
				if get_tree().paused:
					get_tree().paused = false
					PauseMenu.visible = false
				else:
					get_tree().paused = true
					PauseMenu.visible = true
			
