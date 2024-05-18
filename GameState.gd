extends Node

enum {HUB = -1, ILOT = 5555} # HUB position in list

var _debug = true

enum {NONE, WEAK, STRONG} # level of intemperie

enum {CORPORATE, PIRATE}

enum {CAPTAIN, SHIPGIRL, NAVIGATOR1, NAVIGATOR2}

enum {NO_ONE=-9999}

@onready var openworld_packed_scene = preload("res://OpenWorld/open_world.tscn")
@onready var oscillo_packed_scene = preload("res://oscilloscope/oscilloscope_scene.tscn")

########### STATEMACHINE
@onready var ilot_states = {"ilot_1":{"revealed":false},
							"ilot_2":{"revealed":false},
							"ilot_3":{"revealed":false},
							"ilot_4":{"revealed":false},
							"ilot_5":{"revealed":false},
							"ilot_test":{"revealed":false}}
<<<<<<< HEAD
@onready var mission_states = {"mission_1":{"started":false,"finished":false,"in_time":true},
							   "mission_2":{"started":false,"finished":false,"in_time":true},
							   "mission_3":{"started":false,"finished":false,"in_time":true},
							   "mission_4":{"started":false,"finished":false,"in_time":true},
							   "mission_5":{"started":false,"finished":false,"in_time":true}}
@onready var mission_timer = {"mission_1": 60.,
=======
@onready var mission_states = {"mission_1":{"started":false,"finished":false,"in_time":true,"debriefed":false},
							   "mission_2":{"started":false,"finished":false,"in_time":true,"debriefed":false},
							   "mission_3":{"started":false,"finished":false,"in_time":true,"debriefed":false},
							   "mission_4":{"started":false,"finished":false,"in_time":true,"debriefed":false},
							   "mission_5":{"started":false,"finished":false,"in_time":true,"debriefed":false}}
@onready var mission_timer = {"mission_1": 600.,
>>>>>>> 777e67b0a670aebd7fc8d056076527ede6aad810
							   "mission_2": 60.,
							   "mission_3": 60.,
							   "mission_4": 60.,
							   "mission_5": 60.}
@onready var mission_corrupted = {"mission_1": false, #set in each corrupted dialog timeline !
							   "mission_2": false,
							   "mission_3": false,
							   "mission_4": false,
							   "mission_5": false}
@onready var player_position = Vector2(838,4603) # initial coordinates of player

@onready var _title_screen_state : int = CORPORATE

########### ETHER TIMER
var _ether_timer : Timer
var ether_timer_decrement : int = 15

########### ACHIEVEMENTS
@onready var nbCoffee = 0
@onready var coffeeCredit = 3
@onready var nbInteractions = {
	SHIPGIRL:0,
	NAVIGATOR1:0,
	NAVIGATOR2:0,
	CAPTAIN:0}
@onready var nbWard = 0
@onready var nbRetourHub = -1

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

func _ready():
	self.set_process_mode(PROCESS_MODE_ALWAYS)
	self._init_ether_timer()

func setMission_corrupted(which):
	mission_corrupted[which] = true

# Related to dialogs
func start_time_line(timeline_name):
	print(timeline_name)
	if Dialogic.current_timeline == null:
		Dialogic.start(timeline_name).layer = 50

func update_dialogs():
	self._update_characters_availability()
	self._update_current_timelines()

func get_current_timeline(character):
	return self._current_timelines[character]

func start_briefing_dialog():
	if self.coming_from == HUB: # Si on sort du HUB on joue une timeline briefing, sinon non.
		resetPV()
		match self.get_current_mission_idx():
			0: #MISSION 1
				self.start_time_line("tl_mission1_navigator1_objectif")
			1: #MISSION 2
				self.start_time_line("tl_02mission2_objectif")
			2: #MISSION 3
				self.start_time_line("tl_03mission3_objectif")
			3: #MISSION 4
				self.start_time_line("tl_04mission4_objectif")
			4: #MISSION 5
				self.start_time_line("Test_timeline")
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
			else :
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
			self.start_time_line("Test_timeline")
		_: 
			push_error("unexpected behavior, not a recognized mission name")

func _update_current_timelines():
	#HERE WE FUCKING GO
	match self.get_current_mission_idx():
		0: #MISSION 1
			self._current_timelines[GameState.SHIPGIRL] = "tl_hub01_shipgirl"
			self._current_timelines[GameState.NAVIGATOR1] = "tl_hub01_navigator1"
			self._current_timelines[GameState.NAVIGATOR2] = "Test_timeline"
			self._current_timelines[GameState.CAPTAIN] = "tl_hub01_captain"
		1: #MISSION 2
			self._current_timelines[GameState.SHIPGIRL] = "tl_02hub_shipgirl_coffee"
			self._current_timelines[GameState.NAVIGATOR1] = "tl_02hub_navigator1_coffee"
			self._current_timelines[GameState.NAVIGATOR2] = "Test_timeline"
			self._current_timelines[GameState.CAPTAIN] = "tl_02hub_captain_coffee"
		2: #MISSION 3
			if mission_corrupted["mission_1"]:
				self._current_timelines[GameState.SHIPGIRL] = "influenced1/tl_03hub_shipgirl3_coffee_influenced1"
				self._current_timelines[GameState.NAVIGATOR1] = "influenced1/tl_03hub_navigator3_coffee_influenced"
				self._current_timelines[GameState.NAVIGATOR2] = "Test_timeline"
				self._current_timelines[GameState.CAPTAIN] = "influenced1/tl_03hub_captain3_coffee_influenced1"
			else :
				self._current_timelines[GameState.SHIPGIRL] = "tl_03hub_shipgirl3_coffee"
				self._current_timelines[GameState.NAVIGATOR1] = "tl_03hub_navigator1_coffee"
				self._current_timelines[GameState.NAVIGATOR2] = "Test_timeline"
				self._current_timelines[GameState.CAPTAIN] = "tl_03hub_captain3_coffee"
		3: #MISSION 4
			if mission_corrupted["mission_2"]:
				self._current_timelines[GameState.SHIPGIRL] = "influenced2/tl_04hub_shipgirl4_coffee_influenced2"
				self._current_timelines[GameState.NAVIGATOR1] = "influenced2/tl_04hub_navigator4_coffee_influenced2"
				self._current_timelines[GameState.NAVIGATOR2] = "Test_timeline"
				self._current_timelines[GameState.CAPTAIN] = "influenced2/tl_04hub_captain4_coffee_influenced2"
			else :
				self._current_timelines[GameState.SHIPGIRL] = "tl_04hub_shipgirl4_coffee"
				self._current_timelines[GameState.NAVIGATOR1] = "tl_04hub_navigator4_coffee"
				self._current_timelines[GameState.NAVIGATOR2] = "Test_timeline"
				self._current_timelines[GameState.CAPTAIN] = "tl_04hub_captain4_coffee"
		4: #MISSION 5
			self._current_timelines[GameState.SHIPGIRL] = "Test_timeline"
			self._current_timelines[GameState.NAVIGATOR1] = "Test_timeline"
			self._current_timelines[GameState.NAVIGATOR2] = "Test_timeline"
			self._current_timelines[GameState.CAPTAIN] = "Test_timeline"
		_: 
			push_error("unexpected behavior, not a recognized mission name")

func _update_characters_availability():
	pass #NEED SMTH

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
				GameState.start_time_line("Test_timeline")
			else:
				GameState.start_time_line("Test_timeline")
		4: #MISSION 5
			if self.mission_states[mission]["in_time"]:
				GameState.start_time_line("Test_timeline")
			else:
				GameState.start_time_line("Test_timeline")
		_:
			push_error("unexpected_behavior")
	await(Dialogic.timeline_ended)

# Main title relatives
func get_main_title_state():
	return self._title_screen_state

# Ether timer relatives
func _init_ether_timer():
	self._ether_timer = Timer.new()
	self._ether_timer.one_shot = true
	self._ether_timer.timeout.connect(self._on_ether_timer_timeout)
	self.add_child(self._ether_timer)

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
	else:
		push_error("unexpected behavior")

func decrement_ether_timer():
	if self._ether_timer.time_left - self.ether_timer_decrement < 0. :
		_ether_timer.start(0.1)
		pause_ether_timer()
	if not self._ether_timer.is_stopped():
		var p = self._ether_timer.paused
		self._ether_timer.start(self._ether_timer.time_left - self.ether_timer_decrement)
		if p:
			self.pause_ether_timer()

func stop_ether_timer():
	if not self._ether_timer.is_stopped():
		self._ether_timer.stop()
	else:
		push_warning("trying to stop already stopped ether_timer") 

func start_ether_timer():
	if self._ether_timer.is_stopped():
		self._ether_timer.start()
	else:
		push_warning("trying to play already playing ether_timer") 

func pause_ether_timer():
	if not self._ether_timer.is_stopped():
		if self._ether_timer.paused == false:
			self._ether_timer.paused = true
	
func unpause_ether_timer():
	if self._ether_timer.paused == true:
		self._ether_timer.paused = false

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
	var mission_keys = self.mission_states.keys()
	return mission_keys[self.get_current_mission_idx()]
	
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

func validate_current_mission_debug():
	if self._debug:
		var i_mission = self.get_current_mission_idx()
		var mission_str = self.mission_states.keys()[i_mission]
		var ilot_str = self.ilot_states.keys()[i_mission]
		self.mission_states[mission_str]["finished"] = true
		self.ilot_states[ilot_str]["revealed"] = true
		self.start_current_mission()
		self.check_intemperie()
	return self._debug
