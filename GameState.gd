extends Node

enum {HUB = -1} # HUB position in list

var _debug = true

enum {NONE, WEAK, STRONG} # level of intemperie

enum {CORPORATE, PIRATE}

@onready var openworld_packed_scene = preload("res://OpenWorld/open_world.tscn")
@onready var oscillo_packed_scene = preload("res://oscilloscope/oscilloscope_scene.tscn")

########### STATEMACHINE
@onready var ilot_states = {"ilot_1":{"revealed":false},
							"ilot_2":{"revealed":false},
							"ilot_3":{"revealed":false},
							"ilot_4":{"revealed":false},
							"ilot_5":{"revealed":false},
							"ilot_test":{"revealed":false}}
@onready var mission_states = {"mission_1":{"started":false,"finished":false,"in_time":true},
							   "mission_2":{"started":false,"finished":false,"in_time":true},
							   "mission_3":{"started":false,"finished":false,"in_time":true},
							   "mission_4":{"started":false,"finished":false,"in_time":true},
							   "mission_5":{"started":false,"finished":false,"in_time":true}}
@onready var mission_timer = {"mission_1": 600.,
							   "mission_2": 60.,
							   "mission_3": 60.,
							   "mission_4": 60.,
							   "mission_5": 60.}
@onready var player_position = Vector2(838,4603) # initial coordinates of player
var _ether_timer : Timer

@onready var _title_screen_state : int = CORPORATE

########### ACHIEVEMENTS
@onready var nbCoffee = 0
@onready var coffeeCredit = 3
@onready var nbInteractions = {
	"Shipgirl":0,
	"Navigator1":0,
	"Navigator2":0,
	"Captain":0}
@onready var nbWard = 0
@onready var nbRetourHub = -1

func _ready():
	self._init_ether_timer()

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
	if self._ether_timer.is_stopped():
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
