extends Node

enum {HUB = -1} # HUB position in list

enum {NONE, WEAK, STRONG} # level of intemperie

@onready var openworld_packed_scene = preload("res://OpenWorld/open_world.tscn")
@onready var oscillo_packed_scene = preload("res://oscilloscope/oscilloscope_scene.tscn")

@onready var ilot_states = {"ilot_1":{"revealed":false},
							"ilot_2":{"revealed":false},
							"ilot_3":{"revealed":false},
							"ilot_4":{"revealed":false},
							"ilot_5":{"revealed":false},
							"ilot_test":{"revealed":false}}
@onready var mission_states = {"mission_1":{"started":false,"finished":false},
							   "mission_2":{"started":false,"finished":false},
							   "mission_3":{"started":false,"finished":false},
							   "mission_4":{"started":false,"finished":false},
							   "mission_5":{"started":false,"finished":false},
							   "mission_6":{"started":false,"finished":false}}
@onready var mission_timer = {"mission_1": 60.,
							   "mission_2": 60.,
							   "mission_3": 60.,
							   "mission_4": 60.,
							   "mission_5": 60.,
							   "mission_6": 60.}
@onready var player_position = Vector2(838,4603) # initial coordinates of player

########### ACHIEVEMENTS
@onready var nbCoffee = 0
@onready var coffeeCredit = 3
@onready var nbInteractions = {
	"Shipgirl":0,
	"Navigator1":0,
	"Navigator2":0,
	"Captain":0}


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
