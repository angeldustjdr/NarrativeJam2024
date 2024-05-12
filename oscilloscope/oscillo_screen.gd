class_name OscilloscopeScreen

extends ColorRect

var properties = ["ampl","mean","period","phase"]
var properties_ranges = {"ampl":[0.0,2.0],
						"mean":[-1.0,1.0],
						"period":[PI/4.0,8.0*PI],
						"phase":[0.0,2.0*PI]}

# Color parameters
var signal_color = Color(1.0, 1.0, 1.0, 1.0) # Pilotable signal color
var target_signal_color = Color(0.0, 0.0, 1.0, 1.0) # Target signal color


var target_signal_properties = {"ampl":0.5,
								"mean":-0.5,
								"period":4.0*PI,
								"phase":0.5}

var _initial_similarity = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	self._init_pilotable_signal()
	self._init_target_signal()
	self._initial_similarity = max(self.compute_similarity() / 100.0,0.0)

func _init_target_signal():
	$target_signal_shader.set_color(self.target_signal_color)
	for property_name in self.properties:
		var property_range = properties_ranges[property_name]
		var property_value = target_signal_properties[property_name]
		$target_signal_shader.set_property_value(property_name,property_value,property_range)

func _init_pilotable_signal(): # Randomly initialize the pilotable signal in the middle of the bounds of the parameters.
	$pilotable_signal_shader.set_color(self.signal_color)
	for property_name in self.properties:
		var property_range = properties_ranges[property_name]
		var property_value = 0.5*(property_range[0]+property_range[1])
		$pilotable_signal_shader.set_property_value(property_name,property_value,property_range)

func set_pilotable_property_value(property_name,value):
	var property_range = properties_ranges[property_name]
	$pilotable_signal_shader.set_property_value(property_name,value,property_range)
	
func set_pilotable_frequence(frequence):
	$pilotable_signal_shader.set_frequence(frequence)

func set_pilotable_mean(mean):
	$pilotable_signal_shader.set_mean(mean)
	
func set_pilotable_phase(phase):
	$pilotable_signal_shader.set_phase(phase)

func set_pilotable_amplitude(amplitude):
	$pilotable_signal_shader.set_amplitude(amplitude)

func get_uniform_property_range(uniform_property_name):
	if uniform_property_name == "freq":
		return self.properties_ranges["period"]
	else:
		return self.properties_ranges[uniform_property_name]
	
func get_property_value(property_name):
	return $pilotable_signal_shader.get_effective_property_value(property_name)

# Computation of R2 as a similarity coefficient! It seems to work!
func compute_similarity(): 
	var a1 = $pilotable_signal_shader.get_effective_property_value("ampl")
	var mu1 = $pilotable_signal_shader.get_effective_property_value("mean")
	var phi1 = $pilotable_signal_shader.get_effective_property_value("phase")
	var T1 = $pilotable_signal_shader.get_effective_property_value("period")
	var a2 = $target_signal_shader.get_effective_property_value("ampl")
	var mu2 = $target_signal_shader.get_effective_property_value("mean")
	var phi2 = $target_signal_shader.get_effective_property_value("phase")
	var T2 = $target_signal_shader.get_effective_property_value("period")
	var e1 = self._relative_error(a1,a2,"ampl")
	var e2 = self._relative_error(mu1,mu2,"mean")
	var e3 = self._relative_error(T1,T2,"period")
	var e4 = self._relative_error(phi1,phi2,"phase")
	var sim = 1-0.25*e1-0.25*e2-0.25*e3-0.25*e4
	sim = (sim - self._initial_similarity)/(1.0-self._initial_similarity)
	return 100.0*sim

func _relative_error(v1,v2,property_name):
	var property_range = self.properties_ranges[property_name]
	if property_name == "phase":
		return abs(v2-v1)/(property_range[1]-property_range[0])
	else:
		return abs(v2-v1)/(property_range[1]-property_range[0])
